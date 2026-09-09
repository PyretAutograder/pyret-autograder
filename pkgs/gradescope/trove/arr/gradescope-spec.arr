#|
  Copyright (C) 2025 ironmoon <me@ironmoon.dev>

  This file is part of pyret-autograder-gradescope.

  pyret-autograder-gradescope is free software: you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public License as
  published by the Free Software Foundation, either version 3 of the License,
  or (at your option) any later version.

  pyret-autograder-gradescope is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser
  General Public License for more details.

  You should have received a copy of the GNU Lesser General Public License
  with pyret-autograder-gradescope. If not, see <http://www.gnu.org/licenses/>.
|#
import npm("pyret-autograder", "main.arr") as A
import gradescope-output as GO

provide:
  type GradescopeOptions,
  default-options,
  data GradescopeGrader
end

provide from GO:
  data GradescopeVisibility
end

# per-grader gradescope options. new options are new fields here with a
# default below; `gradescope-grader`'s arity never changes.
type GradescopeOptions = {
  visibility :: GO.GradescopeVisibility
}

default-options :: GradescopeOptions = {
  visibility: GO.visible
}

data GradescopeGrader:
  | gradescope-grader(
      grader :: A.Grader<Any, Any, Any>,
      options :: GradescopeOptions)
end
