include file("./core.arr")
include file("./utils.arr")
import string-dict as SD
import error as ERR

provide:
  type Grader,
  data GradingMetadata,
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


type Grader = Node<BlockReason, GradingResult, InternalError, GradingMetadata, GradingInfo>
type Graders = DAG<BlockReason, GradingResult, InternalError, GradingMetadata, GradingInfo>
type GradingRunner = Runner<BlockReason, GradingResult, InternalError, GradingInfo>
type GradingOutcome = Outcome<BlockReason, GradingResult, InternalError, GradingInfo>

# FIXME: artifacts will need more metadata
data GradingMetadata:
  | invisible
  # FIXME: I really don't like this (format-outcome), it requires additional plumbing when constructing a node
  | visible(max-score :: Number, format-outcome :: (GradingOutcome -> AggregateOutput))
sharing:
  method is-visible(self):
    cases (GradingMetadata) self:
      | invisible => false
      | visible(_, _) => true
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

fun is-normalized(val :: Any):
  is-number(val) and (val >= 0) and (val <= 1)
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
  meta-dict = list-to-stringdict(graders.map(lam(n): {n.id; n.metadata} end))
  outcomes = execute(graders)

  var log = ""

  node-results = for fold(acc :: List<{Id; AggregateResult;}> from [list:],
                          key :: Id from outcomes.keys().to-list()) block:
    metadata = meta-dict.get-value(key)
    outcome = outcomes.get-value(key)


    log := log + "### " + key + "\n" +
           cases (GradingOutcome) outcome:
           | block(reason, info) => "blocked for reason" + reason
           | proceed(info) => "proceed"
           | done(res, info) => "graded with " + to-repr(res.earned) + "/1"
           | artifact(path) => "produced an artifact at " + to-repr(path)
           | skipped(id) => "skipped because of " + id
           | internal-error(err) => "produced an internal error! report this to the staff team"
           end + "\n"

    if metadata.is-visible():
      acc-res = cases (GradingOutcome) outcome:
      | block(reason, info) => none
      | proceed(info) => none
      | done(res, info) =>
        output = metadata.format-outcome(res)
        instr-output = info.to-aggregate-output() ^ some
        max-score = metadata.max-score
        scaled-score = res.earned * max-score
        some(aggregate-test(key, output, instr-output, scaled-score, max-score))
      | artifact(path) => some(aggregate-artifact(key, path, none))
      | skipped(id) =>
        some(aggregate-skipped(
          key,
          output-text(
            "test skipped because of " + id + ". Gave reason of " +
            grading-outcome-explanation-to-string(outcomes.get-value(id))
              .or-else("<no reason>") + "."
          ),
          none,
          metadata.max-score # FIXME: this is brittle
        ))
      | internal-error(err) =>
        some(aggregate-skipped(
          key,
          output-text(
            "an internal error occured while running " + key + ". Error: " +
            err.to-string() + "."
          ),
          none,
          metadata.max-score # FIXME: this is brittle
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

