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

student-path = P.example("fold.arr")
functional-path = P.example("fold-grading/functional.arr")

graders =
  [list:
    mk-self-test(
      "gcd-self-test",
      [list: "wf"],
      student-path, "fold",
      1
    ),
    mk-functional(
      "fold-reference-tests", [list: "wf"],
      student-path, functional-path, "fold-reference-tests",
      1
    ),
    mk-well-formed("wf", [list:], student-path),
  ]

inspect-grade(graders)

