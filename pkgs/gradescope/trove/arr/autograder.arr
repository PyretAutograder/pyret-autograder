import npm("pyret-autograder", "core.arr") as CORE
import npm("pyret-autograder", "grading.arr") as GRADING
import npm("pyret-autograder", "grading-builders.arr") as GRADING-BUILDERS

provide from CORE:
  type *,
  data *
end

provide from GRADING:
  type * hiding (TraceEntry, ExecutionTrace, GradingOutput),
  data *,
end

provide from GRADING-BUILDERS:
  *,
  type *,
  data *
end

