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
import file("../../src/common/ast.arr") as CA
include file("../../src/graders/const-def.arr")

check-fn-def = _check-const-def
fmt-fn-def = _fmt-const-def

check "const-def: not present":
  path = P.file("no-bar.arr")
  check-fn-def(path, "bar") is some(const-not-defined("bar"))
end

check "const-def: s-bind":
  path = P.file("bar.arr")
  check-fn-def(path, "bar") is none
end

check "const-def: s-tuple-bind":
  path = P.file("bar-tuple.arr")
  check-fn-def(path, "bar") is none
end

check "fmt-fn-def: totality":
  fmt-fn-def(parser-error(CA.path-doesnt-exist("/invalid/file.arr"))) does-not-raise
  fmt-fn-def(const-not-defined("foo")) does-not-raise
end

