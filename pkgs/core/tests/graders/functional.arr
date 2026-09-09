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
import file("../meta/path-utils.arr") as P
import file("../../src/common/tmp-poc.arr") as AAAA
import file("../../src/common/repl-runner.arr") as R
include file("../../src/main.arr")
include either

student = P.example("fold.arr")
ref-path = P.example("fold-grading/functional.arr")
ref-block-names = [list: "foldl-reference-tests", "foldr-reference-tests"]

fun summary(selector :: R.CheckSelector) -> {Number; Number}:
  cases (Either) AAAA.tmp-run-with-alternate-checks(student, ref-path, selector):
    | left(err) => raise(AAAA.tmp-fmt-ac-err(err))
    | right({passed; total; _; _}) => {passed; total}
  end
end

fun sum-of(summaries :: List<{Number; Number}>) -> {Number; Number}:
  for fold({p; t} from {0; 0}, {sp; st} from summaries):
    {p + sp; t + st}
  end
end

check "all-checks scores the sum of every top-level check block":
  named = ref-block-names.map(lam(n): summary(R.check-named(n)) end)
  summary(R.all-checks) is sum-of(named)
  sum-of(named).{1} is 8
end

check "all-checks on a file without check blocks is an error":
  AAAA.tmp-run-with-alternate-checks(student, P.file("foo-one-arg.arr"), R.all-checks)
    is left(R.ac-no-check-blocks)
end

check "mk-functional-all scales points by summed passed over summed total":
  {passed; total} = summary(R.all-checks)
  grader = mk-functional-all("all", [list:], student, ref-path, 10, none)
  aggregated = grade([list: grader]).aggregated
  aggregated.length() is 1
  agg = aggregated.first
  agg.id is "all"
  agg.name is "Functional Tests in " + ref-path
  agg.max-score is 10
  agg.part is none
  agg.outcome.score is 10 * (passed / total)
end
