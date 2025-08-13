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

fun handle(res, path, name):
  cases (Either) res:
  | left(err) => left(to-repr(err))
  | right(json) =>
    tests = JU.pson(json).get(path).find-match("name", name)
    passed = tests.get("passed").n()
    total = tests.get("total").n()

    if is-left(passed) or is-left(total):
      left("cannot find json: " + to-repr(tests))
    else:
      results = tests
        .get("results").v
        .and-then(lam(x): x.native().map(_.get-value("message")).join-str("\n") end)
        .or-else("")
      right({ passed.v; total.v; results })
    end
  end
end


fun tmp-run-with-alternate-impl(
  student-path :: String, alt-impl-path :: String, fun-name :: String
) -> Either<String, { Number; Number; String }>:
  res = R.run-with-alternate-impl(student-path, alt-impl-path, fun-name)
  handle(res, student-path, fun-name)
end

fun tmp-run-with-alternate-checks(
  student-path :: String, check-path :: String, check-name :: String
) -> Either<String, { Number; Number; String }>:
  res = R.run-with-alternate-checks(student-path, check-path, check-name)
  handle(res, check-path, check-name)
 end


