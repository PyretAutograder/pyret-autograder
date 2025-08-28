fun foo(x):
  if x == 1:
    # because of this shadowing the function name, we cannot make any more
    # recursive calls in this scope. therefore, we do not rename this `foo`
    shadow foo = 1
    foo
  else: x * foo(x - 1)
  end
where:
  foo(5) is 120
  foo(3) is 6
  foo(5) is 0
end
