check "gcd-reference-tests":
  gcd(8, 4) is 4
  gcd(1, 1) is 1
  gcd(0, 16) is 16
  gcd(0, 12) is 12
  gcd(16, 0) is 16
  gcd(7, 0) is 7
  gcd(0, 0) is 0
  gcd(24, 18) is 6
  gcd(27, 16) is 1
  gcd(5, 3) is 1
  gcd(367, 23) is 1
  gcd(64, 16) is 16
  gcd(4, 16) is 4
  gcd(100, 100) is 100
end

check "gcd-prop-reference-tests":
  # would like to override gcd with:
  fun gcd(x, y):
    ask:
      | y == 0 then: x
      | otherwise: gcd(y, num-modulo(x, y))
    end
  end

  gcd-prop(8, 4) is true
  gcd-prop(1, 1) is true
  gcd-prop(0, 16) is true
  gcd-prop(0, 12) is true
  gcd-prop(16, 0) is true
  gcd-prop(7, 0) is true
  # gcd-prop(0, 0) is true # This is an _evil_ test.
  gcd-prop(24, 18) is true
  gcd-prop(27, 16) is true
  gcd-prop(5, 3) is true
  gcd-prop(367, 23) is true
  gcd-prop(64, 16) is true
  gcd-prop(4, 16) is true
  gcd-prop(100, 100) is true
end

check "gcd-prop-non-trivial":
  # would like to override gcd with:
  fun gcd(x,y):
    y
  end

  gcd-prop(8, 4) is true
  gcd-prop(1, 1) is true
  gcd-prop(0, 16) is true
  gcd-prop(0, 12) is true
  gcd-prop(16, 0) raises ""
  gcd-prop(7, 0) raises ""
  gcd-prop(24, 18) raises ""
  gcd-prop(27, 16) raises ""
  gcd-prop(5, 3) raises ""
  gcd-prop(367, 23) raises ""
  gcd-prop(64, 16) is true
  gcd-prop(4, 16) raises ""
  gcd-prop(100, 100) is true
end
