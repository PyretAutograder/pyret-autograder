import npm("pyret-autograder", "main.arr") as A
import prepare-for-gradescope from gradescope-output
import gradescope-spec as GS
import filesystem as FS

import json as J
import string-dict as SD

include lists

provide:
  grade-specification,
  write-results,
  fmt-uncaught-exn
end

fun as-gradescope-graders(spec :: List<Any>) -> List<GS.GradescopeGrader>:
  doc: ```
    Specs predating `gradescope-grader` are bare lists of graders and get
    `default-options`. Mixing the two forms is an error.
  ```
  ask:
    | spec.all(GS.is-gradescope-grader) then: spec
    | spec.any(GS.is-gradescope-grader) then:
      raise("spec mixes `gradescope-grader` entries with bare graders")
    | otherwise: spec.map(GS.gradescope-grader(_, GS.default-options))
  end
end

fun grade-specification(spec :: List<Any>) -> J.JSON:
  graders = as-gradescope-graders(spec)
  visibilities = for fold(acc from [SD.string-dict:], g from graders):
    acc.set(g.grader.id, g.options.visibility)
  end
  prepare-for-gradescope(A.grade(graders.map(_.grader)), visibilities)
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
