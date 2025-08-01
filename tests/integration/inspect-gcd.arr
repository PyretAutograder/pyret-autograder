include file("../../src/main.arr")
include js-file("../../src/utils")

import pathlib as Path

proj-dir = get-proj-dir()
student-path = Path.join(proj-dir, "tests/examples/gcd.arr")
chaff-path = Path.join(proj-dir, "tests/examples/gcd-grading/chaff.arr")
wheat-path = Path.join(proj-dir, "tests/examples/gcd-grading/wheat.arr")
functional-path = Path.join(proj-dir, "tests/examples/gcd-grading/functional.arr")

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

for each(a from result.aggregated):
  print(to-repr(a) + "\n")
end

{student-logs; staff-logs} = summarize-execution-traces(result.trace)

print("==================Student Logs==================\n")
print(student-logs.content + "\n")

print("===================Staff Logs===================\n")
print(staff-logs.content + "\n")
