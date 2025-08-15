
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


# based off https://course.ccs.neu.edu/cs2500accelf23/Homeworks/ps3b.html

import file("../meta/path-utils.arr") as P
include file("../meta/inspect-grade.arr")
include file("../../src/main.arr")
include file("../../src/tools/main.arr")

path = P.example("tower-soln.arr")

graders =
  [list:
    mk-well-formed("wf", [list:], path)
    mk-fn-def-guard("num-rooms-def", [list: "wf"], path, "num-rooms", 1),
    mk-self-test(
      "num-rooms-self-test",
      [list: "num-rooms-def"],
      student-path, "num-rooms",
      1
    ),
    mk-functional(
      "num-rooms-functional",
      [list: "num-rooms-def"],
      student-path, functional-path, "num-rooms-functional",
      4
    ),
    mk-wheat(
      "gcd-wheat-1",
      [list: "num-rooms-def"],
      student-path, wheat-path, "num-rooms",
      1
    ),
    mk-chaff(
      "gcd-chaff-1",
      [list: "num-rooms-def"],
      student-path, chaff-path, "num-rooms",
      1
    ),

    mk-fn-def-guard("max-rooms-def", [list: "wf"], path, "max-rooms", 1),
    mk-fn-def-guard("first-floor-def", [list: "wf"], path, "first-floor", 1),
    mk-fn-def-guard("is-unbalanced-def", [list: "wf"], path, "is-unbalanced", 1),

  ]

# FIXME: nested modules not working
# debugging.wait-for-debugger()

inspect-grade(graders)

