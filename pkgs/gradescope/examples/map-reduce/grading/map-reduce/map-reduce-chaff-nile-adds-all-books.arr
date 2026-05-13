
provide: recommend end
# END HEADER

#| chaff: Adds all books regardless of whether the target book is in the file. |#

# CHAFF DIFFERENCE: missing check that target book is in the file.
fun recommend(title :: String, book-records :: List<Tv-pair<String, List<String>>>)
  -> Tv-pair<Number, List<String>>:
  fun rec-map(file :: Tv-pair<String, List<String>>) -> List<Tv-pair<String, Number>>:
    books = file.value
    books.map({(book): tv(book, if book == title: 0 else: 1 end)})
  end
  result = max-by-val(map-reduce(book-records, rec-map, rec-reduce))
  if result.tag > 0: result else: tv(0, empty) end
end
