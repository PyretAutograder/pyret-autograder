include file("core.arr")
include file("utils.arr")
import string-dict as SD
import error as ERR

provide:
  data GradingMetadata,
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
  grade
end

data GradingMetadata:
  | invisible
  | visible(max_score :: Number)
sharing:
  method is-visible(self):
    cases (GradingMetadata) self:
      | invisible => false
      | visible(_) => true
    end
  end
end
type Graders = DAG<BlockReason, GradingResult, InternalError, GradingMetadata> 
type GradingRunner = Runner<BlockReason, GradingResult, InternalError> 
type GradingOutcome = Outcome<BlockReason, GradingResult, InternalError>

data InternalError:
sharing: 
  method to-string(self): 
    "something went wrong :("
  end
end

data BlockReason:
  # the following are both the result of well-formed
  | cannot-parse(reason :: ERR.ParseError) 
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

data GradingResult:
  | score(earned :: Number, total :: Number)
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
      instructor-output :: Option<AggregateOutput>)
  | aggregate-test(
      name :: String,
      student-output :: AggregateOutput,
      instructor-output :: Option<AggregateOutput>,
      score :: Number,
      max-score :: Number)
  | aggregate-artifact(
      name :: String,
      path :: String,
      extra-data :: Option<Any>)
end


fun grading-outcome-explanation-to-string(outcome :: GradingOutcome) -> Option<String>: 
  cases (GradingOutcome) outcome:
    | block(reason) => some(reason.to-string())
    | internal-error(err) => some(err.to-string())
    | proceed => none
    | done(res) => none
    | artifact(path) => none
    | skipped(id) => none
  end
end

fun grade(graders :: Graders) -> List<{Id; AggregateResult;}> block:
  meta-dict = list-to-stringdict(graders.map(lam(n): {n.id; n.metadata} end))
  outcomes = execute(graders)
  
  # try match the id orderting provided by the graders
  for fold(acc :: List<{Id; AggregateResult;}> from [list:], 
           key :: Id from outcomes.keys().to-list()):
    if meta-dict.get-value(key).is-visible() block:
      outcome = outcomes.get-value(key)
      
      agg-res = cases (GradingOutcome) outcome:
        | block(reason) => none
        | proceed => none
        | done(res) =>
          some(aggregate-test(key, output-text("output"), none,res.earned, res.total))
        | artifact(path) =>
          some(aggregate-artifact(key, path, none))
        | skipped(id) =>
          some(aggregate-skipped(
            key,
            output-text(
              "test skipped because of " + id + ". Gave reason of " +
              grading-outcome-explanation-to-string(outcomes.get-value(id)).or-else("<no reason>") + "."
            ),
            none
          ))
        | internal-error(err) =>
          some(aggregate-skipped(
            key,
            output-text(
              "an internal error occured while running " + key + ". Error: " +
              err.to-string() + "."
            ),
            none
          ))
      end
      
      cases (Option) agg-res:
        | some(res) => link({key; res;}, acc)
        | none => acc
      end
    else: acc
    end
  end
end

