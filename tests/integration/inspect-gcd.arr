import file("../meta/path-utils.arr") as P
include file("../meta/inspect-grade.arr")
include file("../../src/main.arr")
include file("../../src/tools/main.arr")

student-path = P.example("gcd.arr")
chaff-path = P.example("gcd-grading/chaff.arr")
wheat-path = P.example("gcd-grading/wheat.arr")
functional-path = P.example("gcd-grading/functional.arr")

graders =
  [list:
    mk-self-test(
      "gcd-self-test",
      [list: "wf"],
      student-path, "gcd",
      1
    ),
    mk-chaff(
      "gcd-chaff-1",
      [list: "wf"],
      student-path, chaff-path, "gcd",
      1
    ),
    mk-wheat(
      "gcd-wheat-1",
      [list: "wf"],
      student-path, wheat-path, "gcd",
      1
    ),
    mk-functional(
      "gcd-reference-tests", [list: "wf"],
      student-path, functional-path, "gcd-reference-tests",
      1
    ),
    mk-well-formed("wf", [list:], student-path),
  ]

# FIXME: nested modules not working
# debugging.wait-for-debugger()

inspect-grade(graders)

