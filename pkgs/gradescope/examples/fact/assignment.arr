fun fact(n :: Number) -> Number:
  if n <= 0: 1
  else: n * fact(n - 1)
  end
where:
  fact(0) is 1
  fact(1) is 1
  fact(2) is 2
  fact(3) is 6
  fact(4) is 24
end
