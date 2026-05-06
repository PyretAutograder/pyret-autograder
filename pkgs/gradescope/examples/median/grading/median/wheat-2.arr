provide: median end

fun median(lon :: List<Number>) -> Number block:
  if is-empty(lon):
    0
  else:
    sorted = lon.sort()

    if num-modulo(sorted.length(), 2) == 0:
      a = sorted.get((sorted.length() / 2) - 1)
      b = sorted.get(sorted.length() / 2)
      (a + b) / 2
    else:
      sorted.get((sorted.length() - 1) / 2)
    end
  end
end
