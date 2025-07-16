include file("./core.arr")
include file("./utils.arr")
import string-dict as SD
import error as ERR

provide:
  type Grader,
  type Graders,
  data GraderKind,
  type GraderContext,
  data GradingInfo,
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

data TestOutcome:
  | test-ok(score :: Number)
  | test-skipped
end

data ArtifactOutcome:
  | art-ok(path :: String, extra :: Option<Any>) # TODO: remove extra?
  | art-skipped
end

data AggregateResult:
  | agg-test(
      name :: String,
      general-output :: AggregateOutput,
      staff-output :: Option<AggregateOutput>,
      max-score :: Number,
      outcome :: TestOutcome)
  | agg-artifact(
      name :: String,
      description :: Option<AggregateOutput>,
      outcome :: ArtifactOutcome)
end


type GradingRunner = Runner<BlockReason, GradingResult, InternalError, GradingInfo>
type GradingOutcome = Outcome<BlockReason, GradingResult, InternalError>

type GradingOutcomeFormatter = (GradingResult -> AggregateOutput)

type GraderContext = {
  name :: String,
  kind :: GraderKind,
  format-outcome :: GradingOutcomeFormatter,
}

type Grader = Node<BlockReason, GradingResult, InternalError, GraderContext, GradingInfo>
# type Graders = DAG<BlockReason, GradingResult, InternalError, GradingContext, GradingInfo>
type Graders = List<Node<BlockReason, GradingResult, InternalError, GraderContext, GradingInfo>>

data GraderKind:
  | gk-passive
  | gk-scorer(max-score :: Number)
  | gk-artifact
sharing:
  method should-include(self) -> Boolean:
    cases (GraderKind) self:
      | gk-passive => false
      | gk-scorer(_) => true
      | gk-artifact => true
    end
  end,

  method get-max-score(self) -> Option<Number>:
    cases (GraderKind) self:
      | gk-scorer(max-score) => some(max-score)
      | else => none
    end
  end
end

# FIXME: this is a pretty bad abtractions; either use interface or nicer variants
# TODO: this should eventually support recovering the exact tests run to isolate in a REPL
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

# TODO: this doesnt make sense to be centralized
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
  | artifact(path :: String)
end

fun log-outcome(outcome :: GradingOutcome):
  # TODO: add more general logging system, allowing more context for staff
  cases (GradingOutcome) outcome:
    | block(reason) => "blocked for reason" + reason.to-string()
    | noop => "noop"
    | emit(res) => "emitted with " +
      cases (GradingResult) res:
        | score(earned) => "a score of " + to-repr(earned) + " out of 1"
        | artifact(path) => "an artifact at " + path
      end
    | skipped(id) => "skipped because of " + id
    | internal-error(err) => "produced an internal error! report this to the staff team"
  end
end

AGGREGATE-NO-PASSIVE = "disallowed passive grader in aggregate-outcome"
SCORE-NEEDS-MAX = "grader emitting score must have max-score in ctx"

fun raise-internal(reason :: String):
  raise("Fatal Autograder Exception: " + reason)
end

fun grading-skipped-reason(
  outcome :: GradingOutcome
) -> Option<String>:
  cases (GradingOutcome) outcome:
    | block(reason) => some(reason.to-string())
    | internal-error(err) => some(err.to-string())
    | noop => none
    | emit(res) => none
    | skipped(id) => none
  end
end

# invaraint: ctx kind must not be passive
fun aggregate-outcome(
  ctx :: GraderContext,
  outcome :: GradingOutcome,
  info :: GradingInfo,
  all-outcomes :: SD.StringDict<{GradingOutcome; GradingInfo}>
) -> Option<AggregateResult>:
  name = ctx.name

  fun not-run(explanation):
    cases (GraderKind) ctx.kind:
      | gk-passive =>
        raise-internal(AGGREGATE-NO-PASSIVE)
      | gk-scorer(max-score) =>
        agg-test(name, explanation, none, max-score, test-skipped)
      | gk-artifact =>
        agg-artifact(name, some(explanation), art-skipped)
    end
  end

  cases (GradingOutcome) outcome:
    | block(reason) => none
    | noop => none
    | emit(res) =>
      cases (GradingResult) res:
        | score(earned) =>
          max-score = cases (Option) ctx.kind.get-max-score():
            | some(max-score) => max-score
            | none => raise-internal(SCORE-NEEDS-MAX)
          end

          output = ctx.format-outcome(res)
          instr-output = info.to-aggregate-output() ^ some
          scaled-score = res.earned * max-score
          agg-test(name, output, instr-output, max-score, test-ok(scaled-score))
        | artifact(path) =>
          # TODO: does it make sense for this to have info?
          agg-artifact(name, none, art-ok(path, none))
      end ^ some
    | skipped(id) =>
      reason = grading-skipped-reason(all-outcomes.get-value(id).{0})
          .or-else("<no reason>")

      explanation = output-text(
        "test skipped because of " + id + ". Gave reason of " + reason + "."
      )
      some(not-run(explanation))
    | internal-error(err) =>
      explanation = output-text(
        # TODO: details should probably not be shown to the student
        "an internal error occured while running. Error: " +
        err.to-string() + "."
      )
      some(not-run(explanation))
  end
end

fun grade(graders :: Graders) -> {List<{Id; AggregateResult;}>; String} block:
  ctx-dict = list-to-stringdict(graders.map(lam(n): {n.id; n.ctx} end))
  outcomes = execute(graders, lam(id): {skipped(id); grade-info("")} end)

  var log = ""

  node-results = for fold(acc :: List<{Id; AggregateResult;}> from [list:],
                          key :: Id from outcomes.keys-list()) block:
    ctx = ctx-dict.get-value(key)
    {outcome; info} = outcomes.get-value(key)

    log := log + "### " + key + "\n" + log-outcome(outcome) + "\n"

    if ctx.kind.should-include():
      agg-res = aggregate-outcome(ctx, outcome, info, outcomes)
      cases (Option) agg-res:
        | some(res) => link({key; res;}, acc)
        | none => acc
      end
    else:
      acc
    end
  end

  {node-results.reverse(); log}
end

