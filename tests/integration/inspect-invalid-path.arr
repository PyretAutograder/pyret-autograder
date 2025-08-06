import file("../meta/path-utils.arr") as P
include file("../meta/inspect-grade.arr")
include file("../../src/main.arr")

student-path = P.example("really-long-file-name-that-doesnt-exist.arr")

graders =
  [list:
    mk-well-formed("wf", [list:], student-path),
  ]

inspect-grade(graders)

