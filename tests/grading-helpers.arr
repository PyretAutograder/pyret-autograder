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
import file("./meta/path-utils.arr") as P
include file("../src/main.arr")
include file("../src/grading-helpers.arr")

check "aggregate-to-flat":
  aggregated = [list:
    agg-guard("wf", "Wellformed Check", guard-blocked(output-markdown("WF BLOCK REASON"), none)),
    agg-test("gcd-self-test", "Self-Test on gcd", 2, test-skipped("wf"), none),
    agg-test("gcd-chaff-1", "Chaff for gcd", 1, test-skipped("wf"), none),
    agg-test("gcd-wheat-1", "Wheat for gcd", 2, test-skipped("wf"), none),
    agg-test("gcd-reference-tests", "Functional Test for gcd-reference-tests", 5, test-skipped("wf"), none)]

  flat-expected = [list:
    flat-agg-test("Self-Test on gcd", 2, 0, output-markdown("WF BLOCK REASON"), none),
    flat-agg-test("Chaff for gcd", 1, 0, output-markdown("WF BLOCK REASON"), none),
    flat-agg-test("Wheat for gcd", 2, 0, output-markdown("WF BLOCK REASON"), none),
    flat-agg-test("Functional Test for gcd-reference-tests", 5, 0, output-markdown("WF BLOCK REASON"), none)]
  aggregate-to-flat(aggregated) is flat-expected
end


