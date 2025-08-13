include file("./grading.arr")
import lists as L

provide:
  summarize-execution-traces,
  data FlatAggregateResult,
  aggregate-to-flat
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

  # TODO: implement

  {output-markdown(""); output-markdown("")}
end

data FlatAggregateResult:
| flat-agg-test(
    name :: String,
    max-score :: Number,
    score :: Number,
    general-output :: AggregateOutput,
    staff-output :: Option<AggregateOutput>)
| flat-agg-art( # TODO: this needs more thought
    name :: String,
    description :: String,
    path :: String)
end

fun aggregate-to-flat(results :: List<AggregateResult>) -> List<FlatAggregateResult>:
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
      | agg-test(id, name, max, outcome) =>
        new-outs = cases (TestOutcome) outcome:
          | test-ok(points, general, staff) =>
            flat-agg-test(name, max, points, general, staff)
          | test-skipped(skip-id) =>
            cases (Option) L.find({(x): x.id == skip-id}, reasons) block:
              | none =>
                print(to-repr(reasons) + "\n")
                raise("No guard reason found for id: " + skip-id)
              # TODO: better indcate that this was skipped
              | some(p) => flat-agg-test(name, max, 0, p.gen, p.staff)
            end
        end
        ^ link(_, outs)

        {new-outs; reasons}
      | agg-artifact(id, name, desc, outcome) =>
        cases (ArtifactOutcome) outcome:
          | art-ok(path, _) =>
            new-desc = desc.then(_.content).or-else("")
            new-outs = link(flat-agg-art(name, desc, path), outs)
            {new-outs; reasons}
          | art-skipped(_) =>
            # TODO: is this really what we want?
            acc
        end
    end
  end

  outs.reverse()
end
