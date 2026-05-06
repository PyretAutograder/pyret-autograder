provide:
  *,
  type *
end

# 1 for n in {0, 1}, 2 otherwise

fun fact(n :: Number) -> Number:
  if n == 0:
    1
  else if n == 1:
    1
  else: 
    2
  end
end

