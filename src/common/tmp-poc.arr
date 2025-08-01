include file("../utils.arr")
import file("../core.arr") as C
import file("../grading.arr") as G
# TODO: proper implementation
import file("../../poc/runners.arr") as R
import lists as L
include either

provide:
  tmp-run-with-alternate-impl,
  tmp-run-extra-check
end

# TODO:
# - error handling
# - better feedback
# - performance
fun tmp-run-with-alternate-impl(
  student-path :: String, alt-impl-path :: String, fun-name :: String
) -> { Number; Number; String }:
  tests = R.run-with-alternate-impl(student-path, alt-impl-path, fun-name)
  passed = tests.get("passed").n()
  total = tests.get("total").n()

  if is-left(passed) or is-left(total):
    # TODO: this is far from robust
    { 0; 0; "didn't run" }
  else:
    results = tests
      .get("results").v
      .and-then(lam(x): x.native().map(_.get-value("message")).join-str("\n") end)
      .or-else("") # TODO: much nicer error messages when rewritten
    # spy "tmp-run-with-alternate-impl": passed, total, results end
    { passed.v; total.v; results }
  end
end

fun tmp-run-extra-check(
  student-path :: String, check-path :: String, check-name :: String
) -> { Number; Number; String }:
  tests = R.run-extra-check(student-path, check-path, check-name)
  passed = tests.get("passed").n()
  total = tests.get("total").n()


  if is-left(passed) or is-left(total):
    # TODO: this is far from robust
    { 0; 0; "didn't run" }
  else:
    results = tests
      .get("results").v
      .and-then(lam(x): x.native().map(_.get-value("message")).join-str("\n") end)
      .or-else("") # TODO: much nicer error messages when rewritten
    # spy "tmp-run-extra-check": tests, tests-serial: tests.v.and-then(_.serialize()), passed, total, results end
    { passed.v; total.v; results }
  end
end

