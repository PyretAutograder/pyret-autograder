data Foo:
  | foo
end

foo := 1

fun bar(x):
  x + 1
where:
  bar(0) is 1
  bar(1) is 2
  bar(3) is 4
end
