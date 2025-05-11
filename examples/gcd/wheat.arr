# Override gcd with:
fun gcd(x, y):
  ask:
    | y == 0 then: x
    | otherwise: gcd(y, num-modulo(x, y))
  end
end
# And then run _student_ tests. Can we identify `where` block
# for gcd.

