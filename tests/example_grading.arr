# pyret tests/example_grading.arr --compiled-dir .pyret/tests -o tests/example_grading.jarr

include file("../src/grading.arr")
include file("../src/runners/main.arr")
include file("../src/core.arr")
include js-file("../src/utils")

import pathlib as Path

proj-dir = get-proj-dir()
student-path = Path.join(proj-dir, "examples/gcd.arr")
chaff-path = Path.join(proj-dir, "examples/gcd/chaff.arr")
wheat-path = Path.join(proj-dir, "examples/gcd/wheat.arr")
functional-path = Path.join(proj-dir, "examples/gcd/functional.arr")

graders =
  [list:
    node(
      "gcd-chaff-1",
      [list:],
      chaff(student-path, chaff-path, "gcd"),
      visible(1, lam(x): output-markdown("") end)
    ),
    node(
      "gcd-wheat-1",
      [list:],
      wheat(student-path, wheat-path, "gcd"),
      visible(1, lam(x): output-markdown("") end)
    ),
    node(
      "gcd-reference-tests",
      [list:],
      functional(student-path, functional-path, "gcd-reference-tests"),
      visible(1, lam(x): output-markdown("") end)
    )
  ]

{grades; log} = grade(graders)

for each(g from grades):
  print(to-repr(g) + "\n")
end

print(log)

