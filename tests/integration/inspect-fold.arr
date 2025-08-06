import file("../meta/path-utils.arr") as P
include file("../meta/inspect-grade.arr")
include file("../../src/main.arr")

student-path = P.example("fold.arr")
functional-path = P.example("fold-grading/functional.arr")

graders =
  [list:
    mk-self-test(
      "gcd-self-test",
      [list: "wf"],
      student-path, "fold",
      1
    ),
    mk-functional(
      "fold-reference-tests", [list: "wf"],
      student-path, functional-path, "fold-reference-tests",
      1
    ),
    mk-well-formed("wf", [list:], student-path),
  ]

inspect-grade(graders)

