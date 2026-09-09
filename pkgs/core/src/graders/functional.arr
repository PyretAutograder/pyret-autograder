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
import file("../common/repl-runner.arr") as R
import safe-divide from file("../utils/general.arr")
include either
include from C: type Id end
include from G: data AggregateOutput end

provide:
  mk-functional,
  mk-functional-all
end

# TODO: this should be more descriptive
type Info = String

fun score-functional-test(
  student-path :: String, ref-path :: String, selector :: R.CheckSelector
):
  res = AAAA.tmp-run-with-alternate-checks(student-path, ref-path, selector)
  cases(Either) res:
    | left(_) => right({0; res})
    | right({score; total; _; _}) =>
      right({safe-divide(score, total, 0); res})
  end
end

fun fmt-functional-test(target :: String, fun-name :: Option<String>, score :: G.NormalizedNumber, info):
  # TODO: improve both staff and student output
  general = output-markdown(cases(Either) info:
    | left(_) =>
      subject = cases(Option) fun-name:
        | none => target
        | some(fn) => "function `" + fn + "`"
      end
      "An error occured while trying to run our tests against your " +
      subject + ". Make sure your function is defined"
    | right({passed; total; _; _}) =>
      "**" + to-repr(passed) + "** of our **" + to-repr(total) + "** checks " +
      "succeeded against your " + target + "."
  end)
  staff = output-markdown(cases(Either) info:
    | left(err) =>
      AAAA.tmp-fmt-ac-err(err)
    | right({_; _; shadow info; _}) =>
      info
  end) ^ some

  {general; staff}
end

fun mk-functional-grader(
  id :: Id, deps :: List<Id>, student-path :: String, ref-path :: String,
  selector :: R.CheckSelector, points :: Number, fun-name :: Option<String>,
  name :: String, target :: String
):
  scorer = lam(): score-functional-test(student-path, ref-path, selector) end
  calc = GB.simple-calculator
  fmter = fmt-functional-test(target, fun-name, _, _)
  get-rp = AAAA.tmp-extract-ac-ran-program(_, G.rp-staff)
  GB.mk-repl-scorer(id, deps, scorer, name, points, calc, fmter, fun-name, get-rp)
end

# TODO: make fun-name required
fun mk-functional(
  id :: Id, deps :: List<Id>, student-path :: String, ref-path :: String,
  check-name :: String, points :: Number, fun-name :: Option<String>
):
  doc: "Runs the check block named `check-name` from `ref-path` against the student's program."
  mk-functional-grader(
    id, deps, student-path, ref-path, R.check-named(check-name), points, fun-name,
    "Functional Test for " + check-name,
    "implementation in `" + check-name + "`"
  )
end

fun mk-functional-all(
  id :: Id, deps :: List<Id>, student-path :: String, ref-path :: String,
  points :: Number, fun-name :: Option<String>
):
  doc: "Runs every top-level check block in `ref-path` against the student's program, scored together."
  mk-functional-grader(
    id, deps, student-path, ref-path, R.all-checks, points, fun-name,
    "Functional Tests in " + ref-path,
    "implementation"
  )
end

