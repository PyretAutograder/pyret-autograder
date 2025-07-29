include file("./core.arr")
include file("./utils.arr")
include js-file("./utils") # HACK: remove once/if typesystem supports existentials
import string-dict as SD
import error as ERR

provide:
  data AggregateOutput,
  data TestOutcome,
  data ArtifactOutcome,
  data GuardOutcome,
  data AggregateResult,
  type GraderOutput,
  type GraderResult,
  type GradingAggregator,
  type GradingRunner,
  type Grader,
  type NormalizedNumber,
  data GradingResult,
  type TraceEntry,
  type ExecutionTrace,
  type GradingOutput,
  grade,
end

data AggregateOutput:
  | output-text(content :: String)
  | output-markdown(content :: String)
  | output-ansi(content :: String)
end

data TestOutcome:
  | test-ok(score :: Number)
  | test-skipped(id :: Id)
end

data ArtifactOutcome:
  | art-ok(path :: String, extra :: Option<Any>) # TODO: remove extra?
  | art-skipped(id :: Id)
end

data GuardOutcome:
  | guard-passed
  | guard-failed(reason :: AggregateOutput)
  | guard-skipped(id :: Id)
end

data AggregateResult:
  | agg-guard( # TODO: this needs more
      name :: String,
      outcome :: GuardOutcome)
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

type GraderOutput<B, I> = RunnerOutput<B, GradingResult, InternalError, I>
type GraderResult<B, I, C> = NodeResult<B, GradingResult, InternalError, I, C>

type GradingAggregator<B, I, C> =
  (GraderResult<B, I, C> -> Option<AggregateResult>)
type GradingRunner<B, I> = (-> GraderOutput<B, I>)

# trait Grader {
#   type BlockReason
#   type Info
#
#   fn id(): Id;
#   fn deps(): List<Id>;
#   fn run(): GraderOutput<BlockReason, Info>;
#   fn to_aggregate<C>(result: GradingResult<BlockReason, Info, C>): Option<AggregateResult>
# }

# FIXME: this needs existentials
type Grader<B, I, C> = {
  id :: Id,
  deps :: List<Id>,
  run :: GradingRunner<B, I>,
  to-aggregate :: GradingAggregator<B, I, C>
  # TODO: to-repl
}

data InternalError:
sharing:
  method to-string(self):
    "something went wrong :("
  end
end

fun is-normalized(val :: Number):
  (val >= 0) and (val <= 1)
end

type NormalizedNumber = Number%(is-normalized)

# TODO: this could be parameterized too, but not worth it rn
data GradingResult:
  | score(earned :: NormalizedNumber)
  | artifact(path :: String) # TODO: might make more sense to make this an image object
end

type TraceEntry<B, I, C> = {
  id :: Id,
  result :: GraderResult<B, I, C>
}

type ExecutionTrace<B, I, C> = List<TraceEntry<B, I, C>>

type GradingOutput<B, I, C> = {
  aggregated :: List<AggregateResult>,
  trace :: ExecutionTrace<B, I, C>
}

# HACK: these should be existentials, not `Any`
fun grade(graders :: List<Grader<Any, Any, Any>>) -> GradingOutput<Any, Any, Any>:
  dag = for map(grader from graders):
    ctx = {
      to-aggregate: grader.to-aggregate
    }
    node(grader.id, grader.deps, grader.run, ctx)
  end
  results = execute(dag)

  {aggregated; trace} = for fold(
    acc :: {List<AggregateResult>; ExecutionTrace<Any, Any, Any>} from {[list:]; [list:]},
    key :: Id from results.keys-list()
  ):
    {aggregated; trace} = acc
    result = results.get-value(key)

    # FIXME: upcast not needed if existentials are modeled correctly
    new-trace = link(upcast({ id: key, result: result }), trace)

    # TODO: might need to thread trace for combining nodes into single score
    new-aggregated = cases (Option) result.ctx.to-aggregate(result):
      | some(agg) => link(agg, aggregated)
      | none => aggregated
    end

    {new-aggregated; new-trace}
  end

  # FIXME: giant hack, once again need existentials
  dangerously-escape-typesystem({
    aggregated: aggregated.reverse(), # reversed because of link
    trace: trace.reverse(),
  })
end

