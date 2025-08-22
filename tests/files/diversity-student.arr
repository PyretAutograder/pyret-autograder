external-dep = 2

fun foo(a, b):
  id(a + b) * external-dep
where:
  foo(1, 2) is 6
  foo(-1, 1) is 0
  foo(1, 2) is -2
end

fun id(x) block:
  raise(x)
end
