include file("./core.arr")
include file("./utils.arr")
import string-dict as SD
import error as ERR

provide:
  type Grader,
  type GradingContext,
  data GradingInfo,
  type Graders,
  type GradingRunner,
  type GradingOutcome,
  data InternalError,
  data BlockReason,
  data DefType,
  data WrongDefReason,
  data GradingResult,
  data AggregateOutput,
  data AggregateResult,
  data GradingVisibility,
  grade,
end

data AggregateOutput:
  | output-text(content :: String)
  | output-markdown(content :: String)
  | output-ansi(content :: String)
end

data AggregateResult:
  | aggregate-skipped(
      name :: String,
      student-output :: AggregateOutput,
      instructor-output :: Option<AggregateOutput>,
      max-score :: Number)
  | aggregate-test(
      name :: String,
      student-output :: AggregateOutput,
      instructor-output :: Option<AggregateOutput>,
      score :: Number,
      max-score :: Number)
  # FIXME: we need a way to indicate an artifact failure / skip
  | aggregate-artifact(
      name :: String,
      path :: String,
      extra-data :: Option<Any>)
end


type GradingRunner = Runner<BlockReason, GradingResult, InternalError, GradingInfo>
type GradingOutcome = Outcome<BlockReason, GradingResult, InternalError>

type GradingOutcomeFormatter = (GradingResult -> AggregateOutput)

type GradingContext = {
  visibility :: GradingVisibility,
  format-outcome :: GradingOutcomeFormatter,
}

type Grader = Node<BlockReason, GradingResult, InternalError, GradingContext, GradingInfo>
# type Graders = DAG<BlockReason, GradingResult, InternalError, GradingContext, GradingInfo>
type Graders = List<Node<BlockReason, GradingResult, InternalError, GradingContext, GradingInfo>>


# FIXME: artifacts will need more 
data GradingVisibility:
  | invisible
  | visible(max-score :: Number)
sharing:
  method is-visible(self) -> Boolean:
    cases (GradingVisibility) self:
      | invisible => false
      | visible(_) => true
    end
  end,

  method get-max-score(self) -> Option<Number>:
    cases (GradingVisibility) self:
      | invisible => none
      | visible(max-score) => some(max-score)
    end
  end
end

# FIXME: this is a pretty bad abtractions
data GradingInfo:
  | grade-info(msg :: String)
sharing:
  method to-aggregate-output(self) -> AggregateOutput:
    cases (GradingInfo) self:
      | grade-info(msg) => output-markdown(msg)
    end
  end
end

data InternalError:
sharing:
  method to-string(self):
    "something went wrong :("
  end
end

data BlockReason:
  # the following are both the result of well-formed
  | cannot-parse(error :: ERR.ParseError)
  | not-wf(message :: String)

  | br-missing-def(typ :: DefType, name :: String)
  | br-wrong-def(reason :: WrongDefReason, name :: String)

  # todo: remove
  | invalid
sharing:
  method to-string(self):
    "something caused block :("
  end
end

data DefType:
  | dt-const
  | dt-fun
  | dt-data
end

data WrongDefReason:
  | wd-fun-arity(expected :: Number, actual :: Number)
  | wd-fun-contract(expected :: String, actual :: String)
  | wd-data-variant-missing(variant-name :: String)
  | wd-data-variant-arity(expected :: Number, actual :: Number)
  | wd-data-variant-constract(expected :: String, actual :: String)
  | wd-data-unexpected-variant(name :: String)
  | wd-def-type(expected :: DefType, actual :: DefType)
end

fun is-normalized(val :: Number):
  (val >= 0) and (val <= 1)
end

type NormalizedNumber = Number%(is-normalized)

data GradingResult:
  | score(earned :: NormalizedNumber)
end

fun grading-outcome-explanation-to-string(
  outcome :: GradingOutcome
) -> Option<String>:
  cases (GradingOutcome) outcome:
    | block(reason) => some(reason.to-string())
    | internal-error(err) => some(err.to-string())
    | proceed => none
    | done(res) => none
    | artifact(path) => none
    | skipped(id) => none
  end
end

fun grade(graders :: Graders) -> {List<{Id; AggregateResult;}>; String} block:
  ctx-dict = list-to-stringdict(graders.map(lam(n): {n.id; n.metadata} end))
  outcomes = execute(graders, lam(id): {skipped(id); grade-info("")} end)

  var log = ""

  node-results = for fold(acc :: List<{Id; AggregateResult;}> from [list:],
                          key :: Id from outcomes.keys-list()) block:
    ctx = ctx-dict.get-value(key)
    {outcome; info} = outcomes.get-value(key)
    
    log := log + "### " + key + "\n" +
           cases (GradingOutcome) outcome:
           | block(reason) => "blocked for reason" + reason.to-string()
           | proceed => "proceed"
           | done(res) => "graded with " + to-repr(res.earned) + "/1"
           | artifact(path) => "produced an artifact at " + to-repr(path)
           | skipped(id) => "skipped because of " + id
           | internal-error(err) => "produced an internal error! report this to the staff team"
           end + "\n"
    
    if ctx.visibility.is-visible():
      max-score = cases (Option) ctx.visibility.get-max-score():
        | some(x) => x
        | none => raise("INTERNAL ERROR: visible test must have a max-score") 
      end
      
      acc-res = cases (GradingOutcome) outcome:
      | block(reason) => none
      | proceed => none
      | done(res) =>
        output = ctx.format-outcome(res)
        instr-output = info.to-aggregate-output() ^ some
        scaled-score = res.earned * max-score
        some(aggregate-test(key, output, instr-output, scaled-score, max-score))
      | artifact(path) => some(aggregate-artifact(key, path, none))
      | skipped(id) =>
        some(aggregate-skipped(
          key,
          output-text(
            "test skipped because of " + id + ". Gave reason of " +
                grading-outcome-explanation-to-string(outcomes.get-value(id).{0})
              .or-else("<no reason>") + "."
          ),
          none,
          max-score
        ))
      | internal-error(err) =>
        some(aggregate-skipped(
          key,
          output-text(
            "an internal error occured while running " + key + ". Error: " +
            err.to-string() + "."
          ),
          none,
          max-score
        ))
      end

      cases (Option) acc-res:
        | some(res) => link({key; res;}, acc)
        | none => acc
      end
    else:
      acc
    end
  end

  {node-results.reverse(); log}
end

