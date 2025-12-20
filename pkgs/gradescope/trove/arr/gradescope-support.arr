import npm("pyret-autograder", "main.arr") as A
import prepare-for-gradescope from gradescope-output

import json as J

provide:
  grade-specification
end

fun grade-specification(spec :: Any) -> J.JSON:
  # TODO: better input validation
  result = A.grade(spec)

  output = prepare-for-gradescope(result)

  output
end

# TODO: write to gradescope location

