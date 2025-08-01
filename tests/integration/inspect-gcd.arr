include file("../../src/main.arr")
import file("../meta/path-utils.arr") as P
include file("../meta/pp.arr")

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

result = grade(graders)

print("===================Aggregated===================\n")

pretty-aggregate = pretty-print-aggregate-results(result.aggregated, 100)
print(pretty-aggregate + "\n")

{student-logs; staff-logs} = grading-helpers.summarize-execution-traces(result.trace)

print("==================Student Logs==================\n")
print(student-logs.content + "\n")

print("===================Staff Logs===================\n")
print(staff-logs.content + "\n")
