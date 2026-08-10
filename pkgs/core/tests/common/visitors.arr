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
import parse-pyret as PP
import file("../../src/common/visitors.arr") as V

fun pretty(prog) -> String:
  prog.tosource().pretty(80).join-str("\n")
end

remove-all-checks = V.make-check-filter(lam(_): false end)

fun strip(src :: String) -> String:
  parsed = PP.surface-parse(src, "test")
  pretty(parsed.visit(remove-all-checks).visit(V.nothing-stripper))
end

fun expect(src :: String) -> String:
  pretty(PP.surface-parse(src, "test"))
end

check "removing a check between funs preserves their letrec grouping":
  strip(```
    fun f(): g() end
    check "examples": f() is 1 end
    fun g(): 1 end
  ```) is expect(```
    fun f(): g() end
    fun g(): 1 end
  ```)
end

check "nothing in a function body is not stripped":
  strip(```
    fun f() -> Nothing: nothing end
    check: f() is nothing end
  ```) is expect(```
    fun f() -> Nothing: nothing end
  ```)
end

check "a program that is only checks does not become an empty block":
  strip("check: 1 is 1 end") is expect("nothing")
end
