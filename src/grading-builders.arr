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
include either
include file("./core.arr")
include file("./grading.arr")

provide:
  type ComboAggregate,
  type GuardCheck,
  type GuardFormat,
  mk-guard,

  type ScorerRunner,
  type ScorerFormat,
  type ScorerWeight,
  mk-scorer,
  mk-simple-scorer,
  mk-repl-scorer,
  simple-calculator,

  type ArtifactProducer,
  mk-artist,
end

# first element in the tuple represents general output
# second element allows optionally specifying more information to course staff
#   only
type ComboAggregate = {AggregateOutput; Option<AggregateOutput>}

type GuardCheck<BlockReason> = (-> Option<BlockReason>) # TODO: internal error?
type GuardFormat<BlockReason> = (BlockReason -> ComboAggregate)

fun mk-guard<BlockReason, C>(
  id :: Id,
  deps :: List<Id>,
  checker :: GuardCheck<BlockReason>,
  name :: String,
  format :: GuardFormat<BlockReason>
) -> Grader<BlockReason, Nothing, C>:
  {
    id: id,
    deps: deps,
    run: lam():
      cases (Option) checker():
        | none => {noop; nothing}
        | some(reason) => {block(reason); nothing}
      end
    end,
    to-aggregate: lam(result :: GraderResult<BlockReason, Nothing, C>) -> Option<AggregateResult>:
      cases (NodeResult) result:
        | executed(outcome, _, _) =>
          cases (Outcome) outcome:
            | noop => guard-passed
            | block(reason) =>
              {general; staff} = format(reason)
              guard-blocked(general, staff)
            | else => raise("INVARIANT VIOLATED: unexpected outcome")
          end
        | skipped(skip-id, _) => guard-skipped(skip-id)
      end
      ^ agg-guard(id, name, _)
      ^ some
    end,
    to-repl: lam(result :: GraderResult<BlockReason, Nothing, C>) -> Option<RanProgram>:
      none
    end
  }
end

type ScorerRunner<Info> = (-> Either<InternalError, {NormalizedNumber; Info}>)
type ScorerFormat<Info> = (NormalizedNumber, Info -> ComboAggregate)
type ScorerWeight = (NormalizedNumber, Number -> Number)

fun mk-scorer<Info, C>(
  id :: Id,
  deps :: List<Id>,
  scorer :: ScorerRunner<Info>,
  name :: String,
  max-score :: Number,
  calc-score :: ScorerWeight,
  format :: ScorerFormat<Info>,
  part :: Option<String>
) -> Grader<Nothing, Option<Info>, C>:
  INTERNAL-ERROR = "An interal error occured while running this test; " +
                   "please report this to course staff."
  {
    id: id,
    deps: deps,
    run: lam():
      cases (Either) scorer():
        | left(err) => {internal-error(err); none}
        | right({num; info}) => {emit(score(num)); some(info)}
      end
    end,
    to-aggregate: lam(result :: GraderResult<Nothing, Option<Info>, C>) -> Option<AggregateResult>:
      cases (NodeResult) result:
        | executed(outcome, info, _) =>
          cases (Outcome) outcome:
            | emit(res) =>
              cases (GradingResult) res:
                | score(num) =>
                  shadow info = cases (Option) info:
                    | some(shadow info) => info
                    | none => raise("INVARIANT VIOLATED: missing score's info")
                  end
                  realized-score = calc-score(num, max-score)
                  {general; staff} = format(num, info)
                  test-result(realized-score, general, staff)
                | else => raise("INVARIANT VIOLATED: scorer emitted non-score")
              end
            | internal-error(err) =>
              general = output-markdown(INTERNAL-ERROR)
              err-str = err.to-string()
              staff = output-text(err-str) ^ some
              test-result(0, general, staff)
            | else => raise("INVARIANT VIOLATED: unexpected outcome")
          end
        | skipped(skip-id, _) => test-skipped(skip-id)
      end
      ^ agg-test(id, name, max-score, _, part)
      ^ some
    end,
    to-repl: lam(result :: GraderResult<Nothing, Option<Info>, C>) -> Option<RanProgram>:
      none
    end
  }
end

simple-calculator = lam(val, max):
  val * max
end

fun mk-simple-scorer<Info, C>(
  id :: Id,
  deps :: List<Id>,
  scorer :: ScorerRunner<Info>,
  name :: String,
  max-score :: Number,
  format :: ScorerFormat<Info>,
  part :: Option<String>
) -> Grader<Nothing, Option<Info>, C>:
  mk-scorer(id, deps, scorer, name, max-score, simple-calculator, format, part)
end

fun mk-repl-scorer<Info, C>(
  id :: Id,
  deps :: List<Id>,
  scorer :: ScorerRunner<Info>,
  name :: String,
  max-score :: Number,
  calc-score :: ScorerWeight,
  format :: ScorerFormat<Info>,
  part :: Option<String>,
  get-ran-program :: (Info -> Option<RanProgram>)
) -> Grader<Nothing, Option<Info>, C>:
  mk-scorer(id, deps, scorer, name, max-score, calc-score, format, part).{
    to-repl: lam(result :: GraderResult<Nothing, Option<Info>, C>) -> Option<RanProgram>:
      cases (NodeResult) result:
        | executed(outcome, info, _) =>
          cases (Outcome) outcome:
            | emit(_) =>
              cases (Option) info:
                | some(shadow info) => get-ran-program(info)
                | none => none
              end
            | else => none
          end
        | skipped(_, _) => none
      end
    end
  }
end

type ArtifactProducer = (-> Either<InternalError, String>)

fun mk-artist<Info, C>(
  id :: Id, deps :: List<Id>, producer :: ArtifactProducer, name :: String
) -> Grader<Nothing, Option<Info>, C>:
  {
    id: id,
    deps: deps,
    run: lam():
      cases (Either) producer():
        | left(err) => {internal-error(err); none}
        | right({path; info}) => {emit(artifact(path)); some(info)}
      end
    end,
    to-aggregate: lam(result :: GraderResult<Nothing, Option<Info>, C>) -> Option<AggregateResult>:
      cases (NodeResult) result:
        | executed(outcome, info, _) =>
          cases (Outcome) outcome:
            | noop => none
            | emit(res) =>
              cases (GradingResult) res:
                | artifact(path) => some(art-ok(path, none))
                | else => raise("INVARIANT VIOLATED: artist emitted non-artifact")
              end
            | internal-error(err) => none # TODO: error swallowed
            | else => raise("INVARIANT VIOLATED: unexpected outcome")
          end
        | skipped(skip-id, _) => some(art-skipped(skip-id))
      end
        # TODO: description (does this even exist upstream?)
        .and-then(agg-artifact(id, name, none, _))
    end,
    to-repl: lam(result :: GraderResult<Nothing, Option<Info>, C>) -> Option<RanProgram>:
      none
    end
  }
end

