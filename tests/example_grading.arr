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
      "gcd-self-test",
      [list: "wf"],
      self-test(student-path, "gcd"),
      visible(1, lam(x): output-markdown("") end)
    ),
    node(
      "gcd-chaff-1",
      [list: "wf"],
      chaff(student-path, chaff-path, "gcd"),
      visible(1, lam(x): output-markdown("") end)
    ),
    node(
      "gcd-wheat-1",
      [list: "wf"],
      wheat(student-path, wheat-path, "gcd"),
      visible(1, lam(x): output-markdown("") end)
    ),
    node(
      "gcd-reference-tests",
      [list: "wf"],
      functional(student-path, functional-path, "gcd-reference-tests"),
      visible(1, lam(x): output-markdown("") end)
    ),
    node(
      "wf",
      [list:],
      lam(): check-well-formed(student-path) end,
      invisible
    ),
  ]

{grades; log} = grade(graders)

for each(g from grades):
  print(to-repr(g) + "\n")
end

print(log)

