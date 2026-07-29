import file("../meta/path-utils.arr") as P
include file("../meta/inspect-grade.arr")
include file("../../src/main.arr")
include file("../../src/tools/main.arr")

student-path = P.example("double.arr")
wheat-path = P.example("double-grading/wheat.arr")

graders =
  [list:
    mk-well-formed("wf", [list:], student-path),
    mk-import-required(
      "import-image",
      [list: "wf"],
      student-path, "image", some("I")
    ),
    mk-fn-def(
      "double-defined",
      [list: "import-image"],
      student-path, "double", 1
    ),
    mk-wheat(
      "double-wheat",
      [list: "double-defined"],
      student-path, wheat-path, "double",
      1
    )
  ]

result = inspect-grade(graders, true, false)

check "aggregate-to-flat smoke":
  grading-helpers.aggregate-to-flat(result.aggregated) does-not-raise
end
