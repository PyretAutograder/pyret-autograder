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
type Info = Any

type Decider = (Number, Number -> Boolean)

fun score-examplar(
  student-path :: String, alt-impl-path :: String, fun-name :: String,
  decider :: Decider
):
  res = AAAA.tmp-run-with-alternate-impl(student-path, alt-impl-path, fun-name)
  cases(Either) res:
    | left(_) => right({0; res})
    | right({score; total; _}) =>
      right({if decider(score, total): 1 else: 0 end; res})
  end
end

fun fmt-examplar-test(
  score :: G.NormalizedNumber, info :: Info, fun-name :: String,
  adjective :: String, good-str :: String, bad-str :: String
):
  desc = "your tests for `" + fun-name + "` against our " + adjective + " implementation"
  general = output-markdown(cases(Either) info:
    | left(_) =>
      "Somthing went wrong while trying to run " + desc + ".\n\n" +
      "Make sure that your function is defined and has tests using a `with` block." # TODO remove after we have guards
    | right(_) =>
      "Ran " + desc + "; " + ask:
        | score == 0 then: bad-str
        | score == 1 then: good-str
      end
  end)
  # TODO: need to improve output for chaffs where failure is required
  staff = output-text(cases(Either) info:
  | left(err) => "An error occured while running:\n" + to-repr(err)
  | right({_; _; shadow info}) => info
  end) ^ some

  {general; staff}
end

fun mk-examplar(
  id :: Id, deps :: List<Id>, student-path :: String, alt-impl-path :: String,
  fun-name :: String, points :: Number, name :: String, decider :: Decider,
  adjective :: String, good-str :: String, bad-str :: String
):
  scorer = lam():
    score-examplar(student-path, alt-impl-path, fun-name, decider)
  end
  fmter = fmt-examplar-test(_, _, fun-name, adjective, good-str, bad-str)
  GB.mk-simple-scorer(id, deps, scorer, name, points, fmter)
end

# TODO: maybe these should take in a list of implementations
fun mk-wheat(
  id :: Id, deps :: List<Id>, student-path :: String, alt-impl-path :: String,
  fun-name :: String, points :: Number
):
  name = "Wheat for " + fun-name
  decider = _ == _
  good-str = "none of your tests incorrectly failed."
  bad-str = "at least one of your tests failed."
  mk-examplar(
    id, deps, student-path, alt-impl-path, fun-name, points, name, decider,
    "correct", good-str, bad-str
  )
end

fun mk-chaff(
  id :: Id, deps :: List<Id>, student-path :: String, alt-impl-path :: String,
  fun-name :: String, points :: Number
):
  name = "Chaff for " + fun-name
  decider = _ <> _
  good-str = "at least one of your tests caught our bad implementation."
  bad-str = "none of your tests caught it."
  mk-examplar(
    id, deps, student-path, alt-impl-path, fun-name, points, name, decider,
    "incorrect", good-str, bad-str
  )
end
