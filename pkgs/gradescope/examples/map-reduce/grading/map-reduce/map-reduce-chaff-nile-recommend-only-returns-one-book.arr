
provide: recommend end
# END HEADER

#| chaff: recommend only returns the first recommended book. |#

# CHAFF DIFFERENCE: returns only the first book in the result list.
fun recommend(title :: String, book-records :: List<Tv-pair<String, List<String>>>)
  -> Tv-pair<Number, List<String>>:
  fun rec-map(file :: Tv-pair<String, List<String>>) -> List<Tv-pair<String, Number>>:
    books = file.value
    contains-title = books.member(title)
    books.map({(book): tv(book, if contains-title and (book <> title): 1 else: 0 end)})
  end
  out = max-by-val(map-reduce(book-records, rec-map, rec-reduce))
  first-rec = cases (List) out.value:
    | empty => empty
    | link(f, _) => [list: f]
  end
  tv(out.tag, first-rec)
end
