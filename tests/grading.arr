include file("../src/core.arr")
include file("../src/utils.arr")
include file("../src/grading.arr")

check "grading: simple":
  grade(
    [list:
      node("guard_1", [list:], lam(): block(invalid) end, invisible),
      node("guard_2", [list: "guard_1"], lam(): proceed end, invisible),
      node("test_1", [list: "guard_2"], lam(): done(score(10, 10)) end, visible(10))])
  is
  [list:
    {"test_1";
      aggregate-skipped(
        "test_1",
        output-text("test skipped because of guard_1. Gave reason of something caused block :(."),
        none,
        10)
    }]
end

check "grading: must use metadata":
  grade([list: node("test", [list:], lam(): done(score(10, 10)) end, invisible)]) is [list:]
end

