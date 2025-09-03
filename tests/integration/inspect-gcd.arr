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
draw-gcd = P.example("gcd-grading/draw-gcd.arr")

graders =
  [list:
    mk-self-test(
      "gcd-self-test",
      [list: "wf"],
      student-path, "gcd",
      1
    ),
    mk-chaff(
      "gcd-chaff-1",
      [list: "wf"],
      student-path, chaff-path, "gcd",
      1
    ),
    mk-wheat(
      "gcd-wheat-1",
      [list: "wf"],
      student-path, wheat-path, "gcd",
      1
    ),
    mk-functional(
      "gcd-reference-tests", [list: "wf"],
      student-path, functional-path, "gcd-reference-tests",
      1, some("gcd")
    ),
    mk-well-formed("wf", [list:], student-path),
    mk-image-artifact("art", [list:], student-path, draw-gcd, "gcd.png", "GCD")
  ]

# FIXME: nested modules not working
# debugging.wait-for-debugger()

inspect-grade(graders)

