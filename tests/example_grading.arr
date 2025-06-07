# pyret tests/example_grading.arr --compiled-dir .pyret/tests -o tests/example_grading.jarr

include file("../src/grading.arr")
include file("../src/runners/main.arr")
include file("../src/core.arr")

student-path = "examples/gcd.arr"

graders = 
  [list:
    node(
      "gcd-chaff-1", 
      [list:], 
      chaff(student-path, "examples/gcd/wheat.arr", "gcd"),
      visible(1)
    ),
    node(
      "gcd-wheat-1",
      [list:],
      wheat(student-path, "examples/gcd/wheat.arr", "gcd"),
      visible(1)
    ),
    node(
      "gcd-reference-tests",
      [list:],
      functional(student-path, "examples/gcd/functional.arr", "gcd-reference-tests"),
      visible(1)
    )
  ]

result = grade(graders)

print(result)
print("\n")

