
provide: popular-pairs end
# END HEADER

#| chaff: popular-pairs only returns the first book pair. |#

# CHAFF DIFFERENCE: returns only the first pair in the result list.
fun popular-pairs(book-records :: List<Tv-pair<String, List<String>>>)
  -> Tv-pair<Number, List<BookPair>>:
  out = max-by-val(map-reduce(book-records, popular-map, rec-reduce))
  first-pair = cases (List) out.value:
    | empty => empty
    | link(f, _) => [list: f]
  end
  tv(out.tag, first-pair)
end
