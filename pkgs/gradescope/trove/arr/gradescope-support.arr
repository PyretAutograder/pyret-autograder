import npm("pyret-autograder", "main.arr") as A
import prepare-for-gradescope from gradescope-output
import filesystem as FS

import json as J
import string-dict as SD

provide:
  grade-specification,
  write-results,
  fmt-uncaught-exn
end

fun grade-specification(spec :: Any) -> J.JSON:
  # TODO: better input validation
  result = A.grade(spec)

  output = prepare-for-gradescope(result)

  output
end

fun write-results(res :: String) block:
  run-task(lam(): FS.create-dir("./results") end)
  FS.write-file-string("./results/results.json", res)
end

fun fmt-uncaught-exn(exn):
  J.to-json([SD.string-dict:
    "score", 0,
    "output", to-string(exn-unwrap(exn))
  ]).serialize()
end
