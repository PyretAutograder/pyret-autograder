fun is-true(x): x end

type True = Boolean%(is-true)
type Natural = NumInteger%(num-is-non-negative)

fun gcd-prop(x :: Natural, y :: Natural) -> True:
  maybe-gcd = gcd(x, y)
  fun divides(a, b): num-modulo(b, a) == 0 end
  fun common-divisor(a, b, d): divides(d, a) and divides(d, b) end
  
  potential-larger-common-divisors = range(maybe-gcd + 1, num-max(x, y) + 1)
  ((y == 0) and (x == 0) and (maybe-gcd == 0))
  or
  (common-divisor(x, y, maybe-gcd)
    and
    potential-larger-common-divisors.all(lam(d):
          not(common-divisor(x, y, d))
        end))
where:
  gcd-prop(8, 4) is true
  gcd-prop(24, 18) is true
end

fun gcd(shadow x, shadow y):
  y
where:
  gcd(8, 4) is 4
  gcd(24, 18) is 6
  gcd(27, 16) is 1
  gcd(0, 0) is 0
end

check "gcd": 3 + 3 is 6 end
