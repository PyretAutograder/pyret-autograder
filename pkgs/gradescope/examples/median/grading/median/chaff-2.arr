provide: median end

fun median(lon :: List<Number>) -> Number block:
  lon.foldl(_ + _, 0) / lon.length()
end
