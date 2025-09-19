#|
  Copyright (C) 2025 ironmoon <me@ironmoon.dev>

  This file is part of pyret-autograder.

  pyret-autograder is free software: you can redistribute it and/or modify it
  under the terms of the GNU Lesser General Public License as published by the
  Free Software Foundation, either version 3 of the License, or (at your option)
  any later version.

  pyret-autograder is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License
  for more details.

  You should have received a copy of the GNU Lesser General Public License
  with pyret-autograder. If not, see <http://www.gnu.org/licenses/>.
|#
import file("../core.arr") as C
import file("../grading.arr") as G
import file("../grading-builders.arr") as GB
import file("../common/tmp-poc.arr") as AAAA # TODO: proper implementation
import file("../common/ast.arr") as A
import safe-divide from file("../utils/general.arr")
include either
include from C: type Id end
include from G: data AggregateOutput, data RanProgram end

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
    | right({score; total; _; _}) =>
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
      "Something went wrong while trying to run " + desc + ".\n\n" +
      "Make sure that your function is defined and has tests using a `with` block." # TODO remove after we have guards
    | right(_) =>
      "Ran " + desc + "; " + ask:
        | score == 0 then: bad-str
        | score == 1 then: good-str
      end
  end)
  # TODO: need to improve output for chaffs where failure is required
  staff = output-markdown(cases(Either) info:
  | left(err) =>
    "An error occurred while running:\n" +
    AAAA.tmp-fmt-ai-err(err)
  | right({_; _; shadow info; _}) => info
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
  calc = GB.simple-calculator
  fmter = fmt-examplar-test(_, _, fun-name, adjective, good-str, bad-str)
  part = some(fun-name)
  get-rp = AAAA.tmp-extract-ai-ran-program(_, G.rp-staff)
  GB.mk-repl-scorer(id, deps, scorer, name, points, calc, fmter, part, get-rp)
end

# TODO: maybe these should take in a list of implementations
fun mk-wheat(
  id :: Id, deps :: List<Id>, student-path :: String, alt-impl-path :: String,
  fun-name :: String, points :: Number
):
  name = "Your tests for " + fun-name + " against our correct implementation(s)"
  decider = _ == _
  good-str = "all of your tests passed, as they should, since our implementation is correct."
  bad-str = "at least one of your tests failed, which means your tests contain mistakes, since our implementation is correct."
  mk-examplar(
    id, deps, student-path, alt-impl-path, fun-name, points, name, decider,
    "correct", good-str, bad-str
  )
end

fun mk-chaff(
  id :: Id, deps :: List<Id>, student-path :: String, alt-impl-path :: String,
  fun-name :: String, points :: Number
):
  name = "Your tests for " + fun-name + " against our incorrect implementation(s)"
  decider = _ <> _
  good-str = "at least one of your tests successfully identified the mistake in our incorrect implementation."
  bad-str = "all of your tests passed, which means they were not thorough enough to identify the mistake in our incorrect implementation."
  mk-examplar(
    id, deps, student-path, alt-impl-path, fun-name, points, name, decider,
    "incorrect", good-str, bad-str
  )
end
