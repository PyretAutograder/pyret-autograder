include file("../utils.arr")
import file("../core.arr") as C
import file("../grading.arr") as G
# TODO: proper implementation
import file("../../poc/runners.arr") as R
import lists as L

provide:
  validator,
  functional,
  chaff,
  wheat,
end

# TODO:
# - error handling
# - better feedback
# - performance
fun tmp-run-with-alternate-impl(
  student-path :: String, alt-impl-path :: String, fun-name :: String
) -> { Number; Number }:
  tests = R.run-with-alternate-impl(student-path, alt-impl-path, fun-name)
  passed = tests.get("passed").n().v
  total = tests.get("total").n().v
  { passed; total }
end

fun tmp-run-extra-check(
  student-path :: String, check-path :: String, check-name :: String
) -> { Number; Number }:
  tests = R.run-extra-check(student-path, check-path, check-name)
  passed = L.length(tests.get("passed").n().v)
  total = L.length(tests.get("total").n().v)
  { passed; total }
end

# TODO: this needs a better name
fun validator(
  student-path :: String, fun-name :: String
) -> (-> G.GradingOutcome):
  lam(): 
    { passed; total } = tmp-run-with-alternate-impl(student-path, student-path, fun-name)
    score = if total == 0: 0 else: passed / total end
    C.done(G.score(score, 1))
  end
end

fun functional(
  student-path :: String, reference-path :: String, check-name :: String
) -> (-> G.GradingOutcome):
  lam():
    { passed; total } = tmp-run-extra-check(student-path, reference-path, check-name)
    score = if total == 0: 0 else: passed / total end
    C.done(G.score(passed, 1))
  end
end

fun chaff(
  student-path :: String, chaff-path :: String, check-name :: String
) -> (-> G.GradingOutcome):
  lam():
    { passed; total } = tmp-run-with-alternate-impl(student-path, chaff-path, check-name)
    score = if passed <> total: 1 else: 0 end
    C.done(G.score(score, 1))
  end
end

fun wheat(
  student-path :: String, wheat-path :: String, check-name :: String
) -> (-> G.GradingOutcome):
  lam():
    { passed; total } = tmp-run-with-alternate-impl(student-path, wheat-path, check-name)
    score = if passed == total: 1 else: 0 end
    C.done(G.score(score, 1))
  end
end

