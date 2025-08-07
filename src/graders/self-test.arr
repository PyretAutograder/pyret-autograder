import file("../core.arr") as C
import file("../grading.arr") as G
import file("../grading-builders.arr") as GB
import file("../common/tmp-poc.arr") as AAAA # TODO: proper implementation
import safe-divide from file("../utils.arr")
include either
include from C: type Id end
include from G: data AggregateOutput end

provide:
  mk-self-test
end

# TODO: this should be more descriptive
type Info = String

fun score-self-test(path :: String, fun-name :: String):
  {score; total; info} = AAAA.tmp-run-with-alternate-impl(path, path, fun-name)
  right({safe-divide(score, total, 0); info})
end

fun fmt-self-test(score :: G.NormalizedNumber, info):
  doc: ```
    Displays individual test failure *to the student*. Clearly the student can
    run their own tests locally, this is meant primarily as a diagnostic for
    environment setup and context for TAs when grading a student's test cases.
  ```

  # TODO: show number of test passed, format failing test cases nicely
  general = output-text(info)
  staff = none

  {general; staff}
end

fun mk-self-test(
  id :: Id, deps :: List<Id>, path :: String, fun-name :: String,
  points :: Number
):
  name = "Self-Test on " + fun-name
  scorer = lam(): score-self-test(path, fun-name) end
  GB.mk-simple-scorer(id, deps, scorer, name, points, fmt-self-test)
end

