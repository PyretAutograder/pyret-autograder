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
  {score; total; info} = AAAA.tmp-run-with-alternate-checks(student-path, ref-path, check-name)
  right({safe-divide(score, total, 0); info})
end

fun fmt-functional-test(score :: G.NormalizedNumber, info):
  # TODO: improve both staff and student output
  general = "Ran ??? of our tests against your implementation. ??? of ??? passed."
            ^ output-text
  staff = output-text(info) ^ some

  {general; staff}
end

fun mk-functional(
  id :: Id, deps :: List<Id>, student-path :: String, ref-path :: String,
  check-name :: String, points :: Number
):
  name = "Functional Test for " + check-name
  scorer = lam(): score-functional-test(student-path, ref-path, check-name) end
  GB.mk-simple-scorer(id, deps, scorer, name, points, fmt-functional-test)
end

