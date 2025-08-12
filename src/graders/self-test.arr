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
  res = AAAA.tmp-run-with-alternate-impl(path, path, fun-name)
  cases(Either) res:
    | left(_) => right({0; res})
    | right({score; total; _}) =>
      right({safe-divide(score, total, 0); res})
  end
end

fun fmt-self-test(fun-name :: String, score :: G.NormalizedNumber, info):
  doc: ```
    Displays individual test failure *to the student*. Clearly the student can
    run their own tests locally, this is meant primarily as a diagnostic for
    environment setup and context for TAs when grading a student's test cases.
  ```

  general = output-markdown(cases(Either) info:
    | left(err) =>
      "An error occured while trying to run your own tests against your " +
      " implementation of `" + fun-name + "`.\n\n" +
      "The following errors were reported\n" + to-repr(err) # TODO: format nicely
    | right({passed; total; shadow info}) =>
      "**" + to-repr(passed) + "** of your **" + to-repr(total) + "** checks " +
      "succeeded againt your own implementation of `" + fun-name + "`.\n\n" +
      info # TODO: format nicely
  end)
  staff = none

  {general; staff}
end

fun mk-self-test(
  id :: Id, deps :: List<Id>, path :: String, fun-name :: String,
  points :: Number
):
  name = "Self-Test on " + fun-name
  scorer = lam(): score-self-test(path, fun-name) end
  fmter = fmt-self-test(fun-name, _, _)
  GB.mk-simple-scorer(id, deps, scorer, name, points, fmter)
end

