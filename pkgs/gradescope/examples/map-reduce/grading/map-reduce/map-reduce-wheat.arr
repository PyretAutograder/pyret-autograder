
provide: map-reduce, anagram-map, anagram-reduce, recommend, popular-pairs end
# END HEADER

#| wheat (mheller6, Aug 31, 2020):
    Basic wheat; follows specs without additional features. |#

fun map-reduce<A, B, M, N, O>(
    input :: List<Tv-pair<A, B>>,
    mapper :: (Tv-pair<A, B> -> List<Tv-pair<M, N>>),
    reducer :: (Tv-pair<M, List<N>> -> Tv-pair<M, O>))
  -> List<Tv-pair<M, O>>:
  mapped = for fold(mapped from empty, input-pair from input):
    mapped.append(mapper(input-pair))
  end
  grouped = group({(a :: Tv-pair<M, N>, b :: Tv-pair<M, N>): a.tag == b.tag}, mapped)
  for fold(answer from empty, grp :: List<Tv-pair<M, N>> from grouped):
    cases (List) grp:
      | empty => raise("the groups created by the group function cannot be empty")
      | link(first, _) =>
        reduced = reducer(tv(first.tag, map(_.value, grp)))
        link(reduced, answer)
    end
  end
end

fun anagram-map(input :: Tv-pair<String, String>) -> List<Tv-pair<String, String>>:
  map({(word): tv(alphabetize(word), word)}, parse(input.value, " "))
end

fun anagram-reduce(input :: Tv-pair<String, List<String>>) -> Tv-pair<String, List<String>>:
  tv(input.tag, lists.distinct(input.value))
end

fun recommend(title :: String, book-records :: List<Tv-pair<String, List<String>>>)
  -> Tv-pair<Number, List<String>>:
  fun rec-map(file :: Tv-pair<String, List<String>>) -> List<Tv-pair<String, Number>>:
    books = file.value
    contains-title = books.member(title)
    books.map({(book): tv(book, if contains-title and (book <> title): 1 else: 0 end)})
  end
  result = max-by-val(map-reduce(book-records, rec-map, rec-reduce))
  if result.tag > 0: result else: tv(0, empty) end
end

fun popular-pairs(book-records :: List<Tv-pair<String, List<String>>>)
  -> Tv-pair<Number, List<BookPair>>:
  max-by-val(map-reduce(book-records, popular-map, rec-reduce))
end
