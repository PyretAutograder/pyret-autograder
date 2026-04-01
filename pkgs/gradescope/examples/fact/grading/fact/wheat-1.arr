provide:
  *,
  type *
end

# non- tail-recursive

fun fact(n :: Number) -> Number:
  if n == 0:
    1
  else:
    n * fact(n - 1)
  end
end
