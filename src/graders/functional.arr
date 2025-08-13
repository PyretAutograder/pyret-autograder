import file("../core.arr") as C
import file("../grading.arr") as G
import file("../grading-builders.arr") as GB
import file("../common/tmp-poc.arr") as AAAA # TODO: proper implementation
import safe-divide from file("../utils.arr")
include either
include from C: type Id end
include from G: data AggregateOutput end

provide:
  mk-functional
end

# TODO: this should be more descriptive
type Info = String

fun score-functional-test(
  student-path :: String, ref-path :: String, check-name :: String
):
  res = AAAA.tmp-run-with-alternate-checks(student-path, ref-path, check-name)
  cases(Either) res:
    | left(_) => right({0; res})
    | right({score; total; _}) =>
      right({safe-divide(score, total, 0); res})
  end
end

fun fmt-functional-test(check-name :: String, score :: G.NormalizedNumber, info):
  # TODO: improve both staff and student output
  general = output-markdown(cases(Either) info:
    | left(_) =>
      "An error occured while trying to run our tests against your " +
      " implementation in `" + check-name + "`." +
      " Make sure your function is defined"
    | right({passed; total; _}) =>
      "**" + to-repr(passed) + "** of our **" + to-repr(total) + "** checks " +
      "succeeded against your own implementation in `" + check-name + "`."
  end)
  # TODO: format nicely
  staff = output-text(cases(Either) info:
    | left(err) =>
      to-repr(err)
    | right({_; _; shadow info}) =>
      info
  end) ^ some

  {general; staff}
end

fun mk-functional(
  id :: Id, deps :: List<Id>, student-path :: String, ref-path :: String,
  check-name :: String, points :: Number
):
  name = "Functional Test for " + check-name
  scorer = lam(): score-functional-test(student-path, ref-path, check-name) end
  fmter = fmt-functional-test(check-name, _, _)
  GB.mk-simple-scorer(id, deps, scorer, name, points, fmter)
end

