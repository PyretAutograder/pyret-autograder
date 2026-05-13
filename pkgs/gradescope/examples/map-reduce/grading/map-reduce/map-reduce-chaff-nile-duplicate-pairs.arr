
provide: popular-pairs end
# END HEADER

#| chaff: popular-pairs creates both pair(a,b) and pair(b,a) for each book pair. |#

# CHAFF DIFFERENCE: combos creates both orderings of each pair.
fun popular-pairs(book-records :: List<Tv-pair<String, List<String>>>)
  -> Tv-pair<Number, List<BookPair>>:
  fun combos-buggy(lst :: List<String>) -> List<BookPair>:
    cases(List) lst:
      | empty => empty
      | link(first, rest) =>
        map({(elt): pair(first, elt)}, rest)
          .append(map({(elt): pair(elt, first)}, rest))
          .append(combos-buggy(rest))
    end
  end
  fun popular-map-buggy(file :: Tv-pair<String, List<String>>) -> List<Tv-pair<BookPair, Number>>:
    map(tv(_, 1), combos-buggy(file.value))
  end
  max-by-val(map-reduce(book-records, popular-map-buggy, rec-reduce))
end
