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
include file("input.arr")
include file("output.arr")
import npm("pyret-autograder", "main.arr") as A
import json as J

provide:
  grade-pawtograder-spec
end

fun grade-pawtograder-spec(spec :: String) -> J.JSON:
  # this can throw, but that's fine since we don't need to respond gracefully
  # if provided an invalid spec (should be validated using the provided schema)
  spec-json = J.read-json(spec)

  graders = process-spec(spec-json)

  result = A.grade(graders)

  output = prepare-for-pawtograder(result)

  output
end
