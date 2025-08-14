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
import render-error-display as RED
import lists as L
include either

provide:
  tmp-run-with-alternate-impl,
  tmp-run-with-alternate-checks,
  tmp-fmt-ai-err,
  tmp-fmt-ac-err
end

fun handle(res, path, name):
  cases (Either) res:
  | left(err) => left(err)
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
) -> Either<R.RunAltImplErr, { Number; Number; String }>:
  res = R.run-with-alternate-impl(student-path, alt-impl-path, fun-name)
  handle(res, student-path, fun-name)
end

fun tmp-run-with-alternate-checks(
  student-path :: String, check-path :: String, check-name :: String
) -> Either<R.RunAltChecksErr, { Number; Number; String }>:
  res = R.run-with-alternate-checks(student-path, check-path, check-name)
  handle(res, check-path, check-name)
end

fun tmp-fmt-runtime-err(err :: R.RunChecksErr) -> String:
  cases(R.RunChecksErr) err:
    | compile-error(comp-err) =>
      "Program resulted in a compile error:\n" +
      for map(cr from comp-err):
        for map(e from cr.problems):
          RED.display-to-string(e.render-reason(), to-repr, empty)
        end.join-str(",\n")
      end.join-str("\n----\n")
    | runtime-error(run-err) =>
      "Program resulted in a runtime error:\n" +
      "```" + run-err.message + "\n```"
  end
end

fun tmp-fmt-ai-err(err) -> String:
  cases(R.RunAltImplErr) err:
    | ai-cannot-parse-student(shadow err) =>
      "Cannot parse student's file:\n" + to-repr(err)
    | ai-cannot-parse-alt-impl(shadow err) =>
      "Cannot parse specified alt-implementation file:\n" + to-repr(err)
    | ai-missing-replacement-fun(fun-name) =>
      "Cannot find alternate implementation of `" + fun-name +
      "` to use as a replacement."
    | ai-run-err(shadow err) => tmp-fmt-runtime-err(err)
  end
end

fun tmp-fmt-ac-err(err :: R.RunAltChecksErr) -> String:
  cases(R.RunAltChecksErr) err:
    | ac-cannot-parse-student(shadow err) =>
      "Cannot parse student's file:\n" + to-repr(err)
    | ac-cannot-parse-checks(shadow err) =>
      "Cannot parse specified check file:\n" + to-repr(err)
    | ac-cannot-find-check-block(name) =>
      "Cannot find a check block named `" + name + "` in the specified file."
    | ac-run-err(shadow err) => tmp-fmt-runtime-err(err)
  end
end

