fun median(lon :: List<Number>) -> Number block:
  when is-empty(lon):
    raise("Can't find median of empty list")
  end
  sorted = lon.sort()
  len = sorted.length()
  if num-modulo(len, 2) == 0:
    a = sorted.get((len / 2) - 1)
    b = sorted.get(len / 2)
    (a + b) / 2
  else:
    sorted.get((len - 1) / 2)
  end
where:
    median([list: 1, 2, 3]) is 2
    median([list: 1, 2, 3, 4, 5]) is 3
    median([list: 1, 2, 3, 4]) is 2.5
end
