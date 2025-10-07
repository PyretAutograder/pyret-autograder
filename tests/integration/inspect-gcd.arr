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
include file("../meta/inspect-grade.arr")
include file("../../src/main.arr")
include file("../../src/tools/main.arr")


student-path = P.example("gcd.arr")
chaff-path = P.example("gcd-grading/chaff.arr")
wheat-path = P.example("gcd-grading/wheat.arr")
functional-path = P.example("gcd-grading/functional.arr")
draw-gcd = P.example("gcd-grading/gcd-img.arr")

graders =
  [list:
    mk-fn-def(
      "gcd-defined",
      [list: "wf"],
      student-path, "gcd", 2
    ),
    mk-self-test(
      "gcd-self-test",
      [list: "gcd-defined"],
      student-path, "gcd",
      1
    ),
    mk-functional(
      "gcd-reference-tests", [list: "gcd-defined"],
      student-path, functional-path, "gcd-reference-tests",
      1, some("gcd")
    ),
    mk-test-diversity(
      "gcd-diversity",
      [list: "gcd-defined"],
      student-path, "gcd", 3, 2
    ),
    # FIXME: this currently fails because there's no program splicing
    mk-chaff(
      "gcd-chaff-1",
      [list: "gcd-defined", "gcd-diversity"],
      student-path, chaff-path, "gcd",
      1
    ),
    mk-wheat(
      "gcd-wheat-1",
      [list: "gcd-defined", "gcd-diversity"],
      student-path, wheat-path, "gcd",
      1
    ),
    mk-well-formed("wf", [list:], student-path),
    mk-const-def("gcd-img-defined", [list: "wf"], student-path, "gcd-img"),
    mk-image-artifact("art", [list:], student-path, draw-gcd, "gcd.png", "GCD")
  ]

# FIXME: nested modules not working
# debugging.wait-for-debugger()

result = inspect-grade(graders, true, false)

check "aggregate-to-flat smoke":
  grading-helpers.aggregate-to-flat(result.aggregated) does-not-raise
end

