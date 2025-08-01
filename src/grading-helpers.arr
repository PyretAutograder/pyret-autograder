include file("./grading.arr")

provide:
  summarize-execution-traces
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


