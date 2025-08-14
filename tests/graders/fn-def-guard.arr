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
include file("../../src/graders/fn-def-guard.arr")

check-fn-defined = _check-fn-defined
fmt-fn-def = _fmt-fn-def

check "fn-def: not present":
  path = P.file("no-foo.arr")
  check-fn-defined(path, "foo", 1) is some(fn-not-defined("foo", 1))
end

check "fn-def: wrong arity":
  path = P.file("foo-two-args.arr")
  check-fn-defined(path, "foo", 1) is some(wrong-arity("foo", 1, 2))
end

check "fn-def: correct":
  path = P.file("foo-one-arg.arr")
  check-fn-defined(path, "foo", 1) is none
end

check "fmt-fn-def: totality":
  fmt-fn-def(parser-error(CA.path-doesnt-exist("/invalid/file.arr"))) does-not-raise
  fmt-fn-def(fn-not-defined("foo", 1)) does-not-raise
  fmt-fn-def(wrong-arity("foo", 1, 2)) does-not-raise
end
