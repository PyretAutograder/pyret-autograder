provide:
  *,
  type *
end

# iterative, i.e., tail-recursive

fun fact(n :: Number) -> Number:
  fun fact-iter(shadow n :: Number, acc :: Number) -> Number:
    if n == 0:
      acc
    else:
      fact-iter(n - 1, n * acc)
    end
  end
  fact-iter(n, 1)
end
