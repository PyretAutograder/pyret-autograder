provide: median end
# END HEADER

# ---- reference implementation ----

fun median(lon :: List<Number>) -> Number block:
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

# ---- tests ----

check "median":
  # single element
  median([list: 7]) is 7

  # odd-length, already sorted
  median([list: 1, 2, 3]) is 2

  # odd-length, UNSORTED -> catches a "no sort" implementation
  median([list: 5, 3, 1, 2, 4]) is 3

  # even-length, a <> b -> catches "lower on even" / "upper on even"
  median([list: 1, 2, 3, 4]) is 2.5

  # even-length, UNSORTED -> catches no-sort (and lower/upper on even)
  median([list: 4, 1, 3, 2]) is 2.5

  # mean <> median -> catches a "mean" implementation
  median([list: 1, 2, 3, 4, 10]) is 3

  # duplicates present, mode <> median -> catches a "mode" implementation
  median([list: 1, 1, 2, 3, 4]) is 2
end
