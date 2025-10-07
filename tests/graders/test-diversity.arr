import file("../meta/path-utils.arr") as P
import file("../../src/common/ast.arr") as CA
import file("../../src/common/repl-runner.arr") as RR
import json as J
import string-dict as SD

include file("../../src/graders/test-diversity.arr")

check-test-diversity = _check-test-diversity
fmt-test-diversity = _fmt-test-diversity

check "check-test-diversity":
  check-test-diversity(P.file("diversity-student.arr"), "foo", 1, 1) is none
  check-test-diversity(P.file("diversity-student.arr"), "foo", 10, 10)
    is some(too-few-inputs("foo", 10, 2))
  check-test-diversity(P.file("diversity-student.arr"), "foo", 10, 1)
    is some(too-few-inputs("foo", 10, 2))
  check-test-diversity(P.file("diversity-student.arr"), "foo", 1, 10)
    is some(too-few-outputs("foo", 10, 2))
  check-test-diversity(P.file("no-compile.arr"), "bar", 3, 2) satisfies
    {(x):
      cases(Any) x:
        | some(shadow x) =>
          cases(Any) x:
          | run-error(shadow x) =>
            cases(Any) x:
              | compile-error(_, _) => true
              | else => false
            end
          | else => false
          end
        | else => false
      end }
end

check "fmt-test-diversity: smoke":
  fmt-test-diversity(parser-error(CA.path-doesnt-exist("/invalid/file.arr"))) does-not-raise
  fmt-test-diversity(fn-not-defined("foo")) does-not-raise
  fmt-test-diversity(check-test-diversity(P.file("no-compile.arr"), "bar", 3, 2).value) does-not-raise
  fmt-test-diversity(invalid-result(J.j-obj([SD.string-dict:]))) does-not-raise
  fmt-test-diversity(too-few-inputs("foo", 3, 2)) does-not-raise
  fmt-test-diversity(too-few-outputs("foo", 2, 1)) does-not-raise
end

