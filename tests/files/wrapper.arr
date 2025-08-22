import sets as S
import either as E

var foo-diversity-inputs = [S.list-set:]
var foo-diversity-outputs = [S.list-set:]

fun at-least(a, b):
  a >= b
end

fun foo(a, b) block:
  fun student-foo(shadow a, shadow b):
    a + b
  end
  output = cases (E.Either) run-task(lam(): student-foo(a, b) end):
  | left(v) => E.left(v)
  | right(err) => E.right(exn-unwrap(err))
  end
  foo-diversity-inputs := foo-diversity-inputs.add({a; b})
  foo-diversity-outputs := foo-diversity-outputs.add(output)
  output
where:
  foo(1, 2) is 3
  foo(-1, 1) is 0
  foo(1, 2) is 3
end

check "foo: at least 2 test inputs":
  foo-diversity-inputs.size() is%(at-least) 2
end

check "foo: at least 2 test outputs":
  foo-diversity-outputs.size() is%(at-least) 2
end
