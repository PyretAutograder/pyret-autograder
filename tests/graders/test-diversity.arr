import file("../meta/path-utils.arr") as P

include file("../../src/graders/test-diversity.arr")

check-test-diversity = _check-test-diversity

check:
  check-test-diversity(P.file("diversity-student.arr"), "foo", 1, 1) is none
  check-test-diversity(P.file("diversity-student.arr"), "foo", 10, 10)
  is some(too-few-inputs("foo", 10, 2))
  check-test-diversity(P.file("diversity-student.arr"), "foo", 10, 1)
  is some(too-few-inputs("foo", 10, 2))
  check-test-diversity(P.file("diversity-student.arr"), "foo", 1, 10)
  is some(too-few-outputs("foo", 10, 2))
end
