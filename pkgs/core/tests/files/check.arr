foo = lam(x :: Number):
  x + 3
end

check "check name":
  1 is 1
  foo(13) is 16
end

check:
end
