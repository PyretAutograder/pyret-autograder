provide: median end

fun median(lon :: List<Number>) -> Number block:
  when is-empty(lon):
    raise("Can't find median of empty list.")
  end
  
  sorted = lon.sort()

  if num-modulo(sorted.length(), 2) == 0:
    a = sorted.get((sorted.length() / 2) - 1)
    b = sorted.get(sorted.length() / 2)
    b
  else:
    sorted.get((sorted.length() - 1) / 2)
  end
end
