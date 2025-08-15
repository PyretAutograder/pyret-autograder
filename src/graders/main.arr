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
import file("./well-formed.arr") as well-formed
import file("./self-test.arr") as self-test
import file("./functional.arr") as functional
import file("./examplar.arr") as examplar
import file("./fn-def-guard.arr") as fn-def

# NOTE: only provides the functions, everything else should be an
# implementation detail and can be imported directly from the module
# for tests.
provide from well-formed: * end
provide from self-test: * end
provide from functional: * end
provide from examplar: * end
provide from fn-def: * end
