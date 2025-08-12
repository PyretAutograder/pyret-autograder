import file("../meta/path-utils.arr") as P
import file("../../src/common/ast.arr") as CA
include file("../../src/graders/fn-def-guard.arr")

check-fun-defined = _check-fun-defined
fmt-fun-def = _fmt-fun-def

check "fn-def: not present":
  path = P.file("no-foo.arr")
  check-fun-defined(path, "foo", 1) is some(fn-not-defined("foo", 1))
end

check "fn-def: wrong arity":
  path = P.file("foo-two-args.arr")
  check-fun-defined(path, "foo", 1) is some(wrong-arity("foo", 1, 2))
end

check "fn-def: correct":
  path = P.file("foo-one-arg.arr")
  check-fun-defined(path, "foo", 1) is none
end

check "fmt-fun-def: totality":
  fmt-fun-def(parser-error(CA.path-doesnt-exist("/invalid/file.arr"))) does-not-raise
  fmt-fun-def(fn-not-defined("foo", 1)) does-not-raise
  fmt-fun-def(wrong-arity("foo", 1, 2)) does-not-raise
end
