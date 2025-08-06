include file("../utils.arr")
import file("../core.arr") as C
import file("../grading.arr") as G
import file("./repl-runner.arr") as R
import file("../../poc/jsonutils.arr") as JU
import lists as L
include either

provide:
  tmp-run-with-alternate-impl,
  tmp-run-with-alternate-checks
end

fun tmp-run-with-alternate-impl(
  student-path :: String, alt-impl-path :: String, fun-name :: String
) -> { Number; Number; String }:
  res = R.run-with-alternate-impl(student-path, alt-impl-path, fun-name)
  cases(Either) res:
  | left(err) => {0; 0; to-repr(err)}
  | right(json) =>
    tests = JU.pson(json).get(student-path).find-match("name", fun-name)
    passed = tests.get("passed").n()
    total = tests.get("total").n()

    if is-left(passed) or is-left(total):
      { 0; 0; "cannot find json: " + to-repr(tests) }
    else:
      results = tests
        .get("results").v
        .and-then(lam(x): x.native().map(_.get-value("message")).join-str("\n") end)
        .or-else("")
      { passed.v; total.v; results }
    end
  end
end

fun tmp-run-with-alternate-checks(
  student-path :: String, check-path :: String, check-name :: String
) -> { Number; Number; String }:
  res = R.run-with-alternate-checks(student-path, check-path, check-name)
  cases (Either) res:
  | left(err) => {0; 0; to-repr(err)}
  | right(json) =>
    tests = JU.pson(json).get(check-path).find-match("name", check-name)
    passed = tests.get("passed").n()
    total = tests.get("total").n()

    if is-left(passed) or is-left(total):
      { 0; 0; "cannot find json: " + to-repr(tests) }
    else:
      results = tests
        .get("results").v
        .and-then(lam(x): x.native().map(_.get-value("message")).join-str("\n") end)
        .or-else("")
      { passed.v; total.v; results }
    end
  end
end

