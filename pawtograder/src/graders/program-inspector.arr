#|
  Copyright (C) 2025 ironmoon <me@ironmoon.dev>

  This file is part of pyret-autograder-pawtograder.

  pyret-autograder-pawtograder is free software: you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public License as
  published by the Free Software Foundation, either version 3 of the License,
  or (at your option) any later version.

  pyret-autograder-pawtograder is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser
  General Public License for more details.

  You should have received a copy of the GNU Lesser General Public License
  with pyret-autograder-pawtograder. If not, see <http://www.gnu.org/licenses/>.
|#

import npm("pyret-autograder", "main.arr") as A
import parse-path from npm("pyret-autograder", "common/ast.arr")
include either

provide:
  mk-program-inspector,
end

fun score-program-inspector(path :: String):
  cases (Either) parse-path(path):
    | left(err) => left({ to-string: lam(): to-repr(err) end })
    | right(prog) => right({0; lam(): prog end })
  end
end

fun fmt-program-inspector(_, _):
  general = A.output-text(
    "Click \"Interactive Pyret REPL\" below to explore the program that the autograder sees."
  )
  staff = none
  {general; staff}
end

fun get-program(info):
  some(A.rp-general(info()))
end

fun mk-program-inspector(
  id :: A.Id, deps :: List<A.Id>, path :: String
) -> A.Grader:
  name = "Program Inspector"
  calc = A.simple-calculator
  scorer = lam(): score-program-inspector(path) end
  fmter = fmt-program-inspector
  max-score = 0
  part = none
  get-rp = get-program
  A.mk-repl-scorer(id, deps, scorer, name, max-score, calc, fmter, part, get-rp)
end
