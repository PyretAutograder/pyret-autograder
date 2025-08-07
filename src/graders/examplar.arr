import file("../core.arr") as C
import file("../grading.arr") as G
import file("../grading-builders.arr") as GB
import file("../common/tmp-poc.arr") as AAAA # TODO: proper implementation
import safe-divide from file("../utils.arr")
include either
include from C: type Id end
include from G: data AggregateOutput end

provide:
  mk-wheat,
  mk-chaff
end

# TODO: this should be more descriptive
type Info = String

type Decider = (Number, Number -> Boolean)

fun score-examplar(
  student-path :: String, alt-impl-path :: String, fun-name :: String,
  decider :: Decider
):
  {score; total; info} = AAAA.tmp-run-with-alternate-impl(student-path, alt-impl-path, fun-name)
  right({if decider(score, total): 1 else: 0 end; info})
end

fun fmt-examplar-test(
  score :: G.NormalizedNumber, info :: Info, fun-name :: String,
  adjective :: String
):
  # TODO: improve output, should it mention function again? Maybe explain
  # success and failure for each?
  general = output-markdown(
    "Ran your tests for `" + fun-name + "` against our " + adjective + " implementation."
  )
  # TODO: need to improve output for chaffs where failure is required
  staff = output-text(info) ^ some

  {general; staff}
end

fun mk-examplar(
  id :: Id, deps :: List<Id>, student-path :: String, alt-impl-path :: String,
  fun-name :: String, points :: Number, name :: String, decider :: Decider,
  adjective :: String
):
  scorer = lam():
    score-examplar(student-path, alt-impl-path, fun-name, decider)
  end
  fmter = fmt-examplar-test(_, _, fun-name, adjective)
  GB.mk-simple-scorer(id, deps, scorer, name, points, fmter)
end

# TODO: maybe these should take in a list of implementations
fun mk-wheat(
  id :: Id, deps :: List<Id>, student-path :: String, alt-impl-path :: String,
  fun-name :: String, points :: Number
):
  name = "Wheat for " + fun-name
  decider = _ == _
  mk-examplar(
    id, deps, student-path, alt-impl-path, fun-name, points, name, decider,
    "correct"
  )
end

fun mk-chaff(
  id :: Id, deps :: List<Id>, student-path :: String, alt-impl-path :: String,
  fun-name :: String, points :: Number
):
  name = "Chaff for " + fun-name
  decider = _ <> _
  mk-examplar(
    id, deps, student-path, alt-impl-path, fun-name, points, name, decider,
    "incorrect"
  )
end
