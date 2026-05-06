provide: median end

# Note: does mode only when there are duplicate elements; otherwise does median
# This prevents trivial tests from catching it

fun median(lon :: List<Number>) -> Number block:
  fun correct-median(lon :: List<Number>) -> Number block:
    when is-empty(lon):
      raise("Can't find median of empty list.")
    end
    
    sorted = lon.sort()

    if num-modulo(sorted.length(), 2) == 0:
      a = sorted.get((sorted.length() / 2) - 1)
      b = sorted.get(sorted.length() / 2)
      (a + b) / 2
    else:
      sorted.get((sorted.length() - 1) / 2)
    end
  end

  fun mode(lon :: List<Number>) -> {Number; Number} block:
    for fold(best from {0; -1}, ele from lon):
      count = lon.filter(_ == ele).length()
      if count > best.{1}:
        {ele; count}
      else:
        best
      end
    end
  end

  {mode-val; mode-freq} = mode(lon)
  if mode-freq == 1:
    correct-median(lon)
  else:
    mode-val
  end
end

