import file("../meta/path-utils.arr") as P

include file("../../src/graders/test-diversity.arr")

check-test-diversity = _check-test-diversity

check:
  check-test-diversity(P.file("diversity-student.arr"), "foo", 1, 1) is none
end
