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
import js-file("./proj-dir") as PD
import filesystem as F

provide:
  file,
  example
end

proj-dir = PD.get-proj-dir()

fun file(path :: String):
  files-dir = F.join(proj-dir, "tests/files/")
  F.join(files-dir, path)
end

fun example(path :: String):
  examples-dir = F.join(proj-dir, "tests/examples/")
  F.join(examples-dir, path)
end
