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
include file("./grading.arr")
import lists as L

provide:
  summarize-execution-traces,
  data FlatAggregateResult,
  aggregate-to-flat
end

fun summarize-outcome(outcome :: Outcome, is-staff :: Boolean) -> String:
  cases(Outcome) outcome:
    | noop =>
      "no action"
    | emit(res) =>
      "emitting a result of a " +
      cases(GradingResult) res:
        | score(earned) => "score of `" + to-repr(earned) + "`"
        | artifact(path) => "an artifact at `" + path + "`"
      end
    | block(reason) =>
      "blocking further execution due to `" + to-repr(reason) + "`"
    | internal-error(err) =>
      if is-staff:
        "**an internal error**:\n```\n" + err.to-string() + "\n```"
      else:
        "**an internal error (please report this to course staff)**"
      end
  end
end

fun summarize-result(id :: String, result :: NodeResult, is-staff :: Boolean) -> String:
  "### " + id + "\n" +
  cases(NodeResult) result:
    | executed(outcome, info, ctx) =>
      "was run resulting in: " + summarize-outcome(outcome, is-staff) +
      if is-staff and (info <> nothing):
        "\n\nAdditionally it produced the following info:\n" +
        "```\n" + to-repr(info) + "\n```"
      else:
        ""
      end
    | skipped(skip-id, ctx) =>
      "skipped because of " + skip-id + "\n"
  end + "\n\n"
end

fun summarize-execution-traces(
  trace :: ExecutionTrace
) -> {AggregateOutput; AggregateOutput}:
  doc: ```
    Format an execution trace into two text-based summaries:
    - one for student view, showing the results of each node
    - one for staff view, showing detailed information for each summary
      including full error information
  ```

  {student; staff} = for fold({student; staff} from {""; ""}, entry from trace):
    summarize = summarize-result(entry.id, entry.result, _)
    {student + summarize(false); staff + summarize(true)}
  end

  {output-markdown(student); output-markdown(staff)}
end

data FlatAggregateResult:
| flat-agg-test(
    name :: String,
    max-score :: Number,
    score :: Number,
    general-output :: AggregateOutput,
    staff-output :: Option<AggregateOutput>,
    part :: Option<String>)
| flat-agg-art( # TODO: this needs more thought
    name :: String,
    description :: String,
    path :: String)
end

fun aggregate-to-flat(results :: List<AggregateResult>) -> List<{Id; FlatAggregateResult}>:
  {outs; reasons} = for fold(acc from {[list:]; [list:]}, r from results):
    {outs; reasons} = acc
    cases (AggregateResult) r:
      | agg-guard(id, name, outcome) =>
        cases (GuardOutcome) outcome:
          | guard-blocked(gen, staff) =>
            new-reasons = link({ id: id, gen: gen, staff: staff }, reasons)
            {outs; new-reasons}
          | else => acc
        end
      | agg-test(id, name, max, outcome, part) =>
        new-outs = cases (TestOutcome) outcome:
          | test-ok(points, general, staff) =>
            flat-agg-test(name, max, points, general, staff, part)
          | test-skipped(skip-id) =>
            cases (Option) L.find({(x): x.id == skip-id}, reasons) block:
              | none =>
                spy: results, outs, reasons, r end
                raise("No guard reason found for id: " + skip-id)
              # TODO: better indcate that this was skipped
              | some(p) => flat-agg-test(name, max, 0, p.gen, p.staff, part)
            end
        end
        ^ {(x): link({id; x}, outs)}

        {new-outs; reasons}
      | agg-artifact(id, name, desc, outcome) =>
        cases (ArtifactOutcome) outcome:
          | art-ok(path, _) =>
            new-desc = desc.then(_.content).or-else("")
            new-outs = link({id; flat-agg-art(name, desc, path)}, outs)
            {new-outs; reasons}
          | art-skipped(_) =>
            # TODO: is this really what we want?
            acc
        end
    end
  end

  outs.reverse()
end
