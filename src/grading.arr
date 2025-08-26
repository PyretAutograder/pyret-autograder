#|
  Copyright (C) 2025 ironmoon <me@ironmoon.dev>

  This file is part of pyret-autograder.

  pyret-autograder is free software: you can redistribute it and/or modify it
  under the terms of the GNU Lesser General Public License as published by the
  Free Software Foundation, either version 3 of the License, or (at your option)
  any later version.

  pyret-autograder is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License
  for more details.

  You should have received a copy of the GNU Lesser General Public License
  with pyret-autograder. If not, see <http://www.gnu.org/licenses/>.
|#
include file("./core.arr")
include file("./utils/general.arr")
include js-file("./escape-hatch") # HACK: remove once/if typesystem supports existentials
import ast as A
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
  type InternalError,
  type NormalizedNumber,
  data GradingResult,
  type TraceEntry,
  type ExecutionTrace,
  type GradingOutput,
  data RanProgram,
  grade,
end

data AggregateOutput:
  | output-text(content :: String)
  | output-markdown(content :: String)
  | output-ansi(content :: String)
end

data RanProgram:
  | rp-general(program :: A.Program)
  | rp-staff(program :: A.Program)
end

data GuardOutcome:
  | guard-passed
  | guard-blocked(
      general-output :: AggregateOutput,
      staff-output :: Option<AggregateOutput>)
  | guard-skipped(id :: Id)
end

data TestOutcome:
  | test-result(
      score :: Number,
      general-output :: AggregateOutput,
      staff-output :: Option<AggregateOutput>)
  | test-skipped(id :: Id)
end

data ArtifactOutcome:
  | art-ok(path :: String, extra :: Option<Any>) # TODO: remove extra?
  | art-skipped(id :: Id)
end

# TODO: this whole structure needs some work, its not very aggregate anymore
data AggregateResult:
  | agg-guard( # TODO: this needs more
      id :: Id,
      name :: String,
      outcome :: GuardOutcome)
  | agg-test(
      id :: Id,
      name :: String,
      max-score :: Number,
      outcome :: TestOutcome,
      part :: Option<String>)
  | agg-artifact(
      id :: Id,
      name :: String,
      description :: Option<AggregateOutput>,
      outcome :: ArtifactOutcome)
end

type InternalError = {
  to-string :: (-> String)
}

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
  to-aggregate :: GradingAggregator<B, I, C>,
  to-repl :: (GraderResult<B, I, C> -> Option<RanProgram>)
}


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
  trace :: ExecutionTrace<B, I, C>,
  repl-programs :: SD.StringDict<RanProgram>
}

# HACK: these should be existentials, not `Any`
fun grade(graders :: List<Grader<Any, Any, Any>>) -> GradingOutput<Any, Any, Any>:
  dag = for map(grader from graders):
    ctx = {
      to-aggregate: grader.to-aggregate,
      to-repl: grader.to-repl
    }
    node(grader.id, grader.deps, grader.run, ctx)
  end
  results = execute(dag)

  {aggregated; trace; repl-programs} = for fold(
    acc :: {List<AggregateResult>; ExecutionTrace<Any, Any, Any>; SD.StringDict<RanProgram>} from {[list:]; [list:]; [SD.string-dict:]},
    {id; result} from results
  ) block:
    print("grade: " + id + "\n")
    {aggregated; trace; repl-programs} = acc

    # FIXME: upcast not needed if existentials are modeled correctly
    new-trace = link(upcast({ id: id, result: result }), trace)

    # TODO: might need to thread trace for combining nodes into single score
    new-aggregated = cases (Option) result.ctx.to-aggregate(result):
      | some(agg) => link(agg, aggregated)
      | none => aggregated
    end

    new-repl-programs = cases (Option) result.ctx.to-repl(result):
      | some(program-run) => repl-programs.set(id, program-run)
      | none => repl-programs
    end

    {new-aggregated; new-trace; new-repl-programs}
  end

  # FIXME: giant hack, once again need existentials
  escape-typesystem({
    aggregated: aggregated.reverse(), # reversed because of link
    trace: trace.reverse(),
    repl-programs: repl-programs
  })
end

