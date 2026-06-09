provide: map-reduce, anagram-map, anagram-reduce, recommend, popular-pairs end
# END HEADER

include file("submission/assignment-support.arr")
import distinct, partition from lists

# ---- reference implementation -------------------------------------------
# The full implementation lives here (not in assignment-support.arr) so that
# the name-based wheat/chaff merge can replace ANY function a mutant changes,
# including helpers such as `combos` that a chaff rewrites.

fun parse(str :: String, delim :: String) -> List<String>:
  doc: ```Parses str into words separated by the delimeter delim. Words can
       be divided by any number of the delimeter```
  filter({(word): not(word == "")}, string-split-all(str, delim))
end

fun group<A>(pred :: (A, A -> Boolean), l :: List<A>) -> List<List<A>>:
  doc: ```pred is an equivalence relation on l. The function returns a list of
       equivalence classes of the elements of l under pred.```
  cases(List) l:
    | empty => empty
    | link(first, rest) =>
      split = partition(pred(first, _), l)
      link(split.is-true, group(pred, split.is-false))
  end
end

fun map-reduce<A, B, M, N, O>(
    input :: List<Tv-pair<A, B>>,
    mapper :: (Tv-pair<A, B> -> List<Tv-pair<M, N>>),
    reducer :: (Tv-pair<M, List<N>> -> Tv-pair<M, O>))
  -> List<Tv-pair<M, O>>:
  mapped :: List<Tv-pair<M, N>> = for fold(mapped from empty, input-pair from input):
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

fun list-to-string(l :: List<String>) -> String:
  doc: "concatenates the elements of the list which must be a list of strings"
  fold(_ + _, "", l)
end

fun alphabetize(str :: String) -> String:
  doc: "rearranges the letters of str into alphabetical order"
  list-to-string(string-explode(str).sort())
end

fun anagram-map(input :: Tv-pair<String, String>) -> List<Tv-pair<String, String>>:
  words = parse(input.value, " ")
  map({(word): tv(alphabetize(word), word)}, words)
end

fun anagram-reduce(input :: Tv-pair<String, List<String>>) -> Tv-pair<String, List<String>>:
  tv(input.tag, distinct(input.value))
end

fun max-by-val<A>(pairs :: List<Tv-pair<A, Number>>) -> Tv-pair<Number, List<A>>:
  max-val = fold(num-max, 0, map(_.value, pairs))
  shadow pairs = filter({(p): p.value == max-val}, pairs)
  tv(max-val, map(_.tag, pairs))
end

fun rec-reduce<M>(recs :: Tv-pair<M, List<Number>>) -> Tv-pair<M, Number>:
  tv(recs.tag, fold(_ + _, 0, recs.value))
end

fun recommend(title :: String, book-records :: List<Tv-pair<String, List<String>>>)
  -> Tv-pair<Number, List<String>>:
  fun rec-map<A>(file :: Tv-pair<A, List<String>>) -> List<Tv-pair<String, Number>>:
    doc: ```the mapper for recommend. the file's first field doesn't matter and
         the second contains a list of distinct book names. It returns a list of
         tv-pairs of (book name, 1 if it was paired with title else 0)```
    books = file.value
    contains-title = books.member(title)
    paired = {(book): contains-title and (book <> title)}
    books.map({(book): tv(book, if paired(book): 1 else: 0 end)})
  end
  result = max-by-val(map-reduce(book-records, rec-map, rec-reduce))
  if result.tag > 0:
    result
  else:
    tv(0, empty)
  end
end

fun combos(lst :: List<String>) -> List<BookPair>:
  fun min(a :: String, b :: String) -> String: if a < b: a else: b end end
  fun max(a :: String, b :: String) -> String: if a < b: b else: a end end
  cases(List) lst:
    | empty => empty
    | link(first, rest) =>
      map({(elt): pair(min(first, elt), max(first, elt))}, rest)
        .append(combos(rest))
  end
end

fun popular-map(file :: Tv-pair<String, List<String>>) -> List<Tv-pair<BookPair, Number>>:
  map(tv(_, 1), combos(file.value))
end

fun popular-pairs(book-records :: List<Tv-pair<String, List<String>>>)
  -> Tv-pair<Number, List<BookPair>>:
  max-by-val(map-reduce(book-records, popular-map, rec-reduce))
end

# ---- test helpers -------------------------------------------------------

fun is-permutation(l1 :: List<Any>, l2 :: List<Any>, equiv :: (Any, Any -> Boolean))
  -> Boolean:
  doc: "returns true if l1 and l2 are permutations under the equivalence relation equiv"
  fun multiplicity(elem :: Any, l :: List<Any>) -> Number:
    for fold(ans from 0, e from l): ans + (if equiv(e, elem): 1 else: 0 end) end
  end
  cases(List) l1:
    | empty => l2 == empty
    | link(first, _) => (multiplicity(first, l1) == multiplicity(first, l2)) and
      is-permutation(for filter(e from l1): not(equiv(e, first)) end,
        for filter(e from l2): not(equiv(e, first)) end, equiv)
  end
end

fun anagram-equiv(t1 :: Tv-pair<Any, List<Any>>, t2 :: Tv-pair<Any, List<Any>>) -> Boolean:
  is-permutation(t1.value, t2.value, lam(x, y): x == y end)
end

fun unique-tags(pairs :: List<Tv-pair<Any, List<Any>>>) -> Boolean:
  doc: "Checks that the tags in a list of tv-pairs are unique"
  cases(List) pairs:
    | empty => true
    | link(f, r) => is-empty(filter(lam(e): e.tag == f.tag end, r)) and unique-tags(r)
  end
end

fun popular-equiv(t1 :: Tv-pair<Any, List<Any>>, t2 :: Tv-pair<Any, List<Any>>) -> Boolean:
  (t1.tag == t2.tag) and is-permutation(t1.value, t2.value, lam(x, y): x == y end)
end

# ---- fixtures -----------------------------------------------------------

AF1 = tv("f1", "hello holle stat")
AF2 = tv("f2", "tats ana elloh")
AF3 = tv("f3", "no anagrams hello naa")
AF4 = tv("f4", "internet-anagram-server i-rearrangement-servant")
AF5 = tv("f5", "dictionary elvis listen")
AF6 = tv("f6", "indicatory lives deirram silent")
AF7 = tv("f7", "admirer married slive")
AF8 = tv("f8", "olleh ELloh TATS")

NF1 = tv("file1", [list: "ULYSSES by James Joyce",
    "A PORTRAIT OF THE ARTIST AS A YOUNG MAN by James Joyce",
    "BRAVE NEW WORLD by Aldous Huxley",
    "CATCH-22 by Joseph Heller",
    "SONS AND LOVERS by D.H. Lawrence"])
NF2 = tv("file2", [list: "ULYSSES by James Joyce",
    "CATCH-22 by Joseph Heller",
    "SONS AND LOVERS by D.H. Lawrence"])
NF3 = tv("file3", [list: "ULYSSES by James Joyce",
    "CATCH-22 by Joseph Heller"])

RECS11 = tv("recs1",
  [list: "Harry Potter", "Twilight", "Anna Karenina", "Moby Dick",
    "Surely You're Joking Mr Feynman"])
RECS21 = tv("recs2",
  [list: "Moby Dick", "Harry Potter", "The Great Gatsby",
    "Surely You're Joking Mr Feynman"])
RECS31 = tv("recs3",
  [list: "Frankenstein", "Hamlet", "Twilight", "Anna Karenina",
    "Surely You're Joking Mr Feynman"])
RECS41 = tv("recs4",
  [list: "Surely You're Joking Mr Feynman", "Moby Dick", "Hamlet",
    "Harry Potter"])
BLIST11 = [list: RECS11, RECS21, RECS31, RECS41]
BLIST21 = [list: RECS21, RECS41]
BLIST31 = [list: RECS11, RECS31]

bl1 = tv("1", [list: "aa", "bb", "cc", "dd", "ee", "ff", "gg"])
bl2 = tv("2", [list: "aa", "bb"])
bl3 = tv("3", [list: "aa", "bb", "cc", "dd"])
bl4 = tv("4", [list: "ff", "dd", "ee"])
bl5 = tv("5", [list: "bb", "aa"])

# ---- tests, routed per function under test ------------------------------

check "map-reduce":
  # empty input
  map-reduce(empty, anagram-map, anagram-reduce) is empty

  # groups equivalence classes ACROSS files (the core map-reduce behaviour)
  is-permutation(map-reduce([list: AF1, AF2, AF3], anagram-map, anagram-reduce),
    [list: tv("ehllo", [list: "hello", "holle", "elloh"]),
      tv("astt", [list: "stat", "tats"]),
      tv("aan", [list: "ana", "naa"]),
      tv("no", [list: "no"]),
      tv("aaagmnrs", [list: "anagrams"])],
    anagram-equiv) is true

  is-permutation(map-reduce([list: AF4, AF5, AF6, AF7], anagram-map, anagram-reduce),
    [list: tv("eilnst", [list: "silent", "listen"]),
      tv("adeimrr", [list: "deirram", "admirer", "married"]),
      tv("acdiinorty", [list: "indicatory", "dictionary"]),
      tv("eilsv", [list: "elvis", "lives", "slive"]),
      tv("--aaaeeeegimnnnrrrrsttv",
        [list: "i-rearrangement-servant", "internet-anagram-server"])],
    anagram-equiv) is true
end

check "anagram-map":
  # one file with one word
  is-permutation(map-reduce([list: tv("file", "hi")], anagram-map, anagram-reduce),
    [list: tv("hi", [list: "hi"])], anagram-equiv) is true

  # case sensitivity: "ELloh" and "TATS" must NOT group with "hello"/"stat"
  is-permutation(map-reduce([list: AF1, AF8], anagram-map, anagram-reduce),
    [list: tv("hello", [list: "hello", "olleh", "holle"]),
      tv("stat", [list: "stat"]), tv("a", [list: "ELloh"]),
      tv("b", [list: "TATS"])], anagram-equiv) is true

  # normal grouping by anagram
  is-permutation(map-reduce([list: AF1, AF2], anagram-map, anagram-reduce),
    [list: tv("ehllo", [list: "hello", "holle", "elloh"]),
      tv("astt", [list: "stat", "tats"]),
      tv("aan", [list: "ana"])],
    anagram-equiv) is true
end

check "anagram-reduce":
  # tags must be unique (one tv-pair per anagram class)
  unique-tags(map-reduce([list: AF1, AF2, AF3], anagram-map, anagram-reduce)) is true

  # duplicate values must be collapsed (AF5 supplied twice)
  is-permutation(map-reduce([list: AF5, AF5], anagram-map, anagram-reduce),
    [list: tv("eilsv", [list: "elvis"]),
      tv("eilnst", [list: "listen"]),
      tv("acdiinorty", [list: "dictionary"])],
    anagram-equiv) is true
end

check "recommend":
  # a book that does not exist anywhere -> no recommendation
  recommend-equiv(recommend("does not exist", [list: NF1, NF2, NF3]),
    tv(0, empty)) is true

  # two-element file: recommends the other book
  recommend-equiv(recommend("CATCH-22 by Joseph Heller", [list: NF3]),
    tv(1, [list: "ULYSSES by James Joyce"])) is true

  # single most popularly paired book
  recommend-equiv(recommend("ULYSSES by James Joyce", [list: NF1, NF2, NF3]),
    tv(3, [list: "CATCH-22 by Joseph Heller"])) is true
  recommend-equiv(recommend("Hamlet", BLIST11),
    tv(2, [list: "Surely You're Joking Mr Feynman"])) is true

  # multiple, equally most popular books
  recommend-equiv(recommend("SONS AND LOVERS by D.H. Lawrence", [list: NF1, NF2, NF3]),
    tv(2, [list: "CATCH-22 by Joseph Heller", "ULYSSES by James Joyce"])) is true
  recommend-equiv(recommend("Harry Potter", BLIST11),
    tv(3, [list: "Surely You're Joking Mr Feynman", "Moby Dick"])) is true
  recommend-equiv(recommend("Moby Dick", BLIST11),
    tv(3, [list: "Surely You're Joking Mr Feynman", "Harry Potter"])) is true
end

check "popular-pairs":
  # no books
  popular-equiv(popular-pairs(empty), tv(0, empty)) is true

  # one most popular pair
  popular-equiv(popular-pairs([list: NF1, NF2, NF3]),
    tv(3, [list: pair("CATCH-22 by Joseph Heller", "ULYSSES by James Joyce")])) is true

  # multiple equally most popular pairs
  popular-equiv(popular-pairs([list: NF1, NF2]),
    tv(2, [list: pair("CATCH-22 by Joseph Heller", "ULYSSES by James Joyce"),
        pair("SONS AND LOVERS by D.H. Lawrence", "ULYSSES by James Joyce"),
        pair("CATCH-22 by Joseph Heller", "SONS AND LOVERS by D.H. Lawrence")]))
    is true
  popular-equiv(popular-pairs(BLIST11),
    tv(3, [list: pair("Moby Dick", "Surely You're Joking Mr Feynman"),
        pair("Harry Potter", "Surely You're Joking Mr Feynman"),
        pair("Harry Potter", "Moby Dick")])) is true
  popular-equiv(popular-pairs(BLIST21),
    tv(2, [list: pair("Harry Potter", "Surely You're Joking Mr Feynman"),
        pair("Moby Dick", "Surely You're Joking Mr Feynman"),
        pair("Harry Potter", "Moby Dick")])) is true

  # one file only
  popular-equiv(popular-pairs([list: bl4]), tv(1, [list: pair("ff", "dd"),
        pair("ee", "ff"), pair("dd", "ee")])) is true

  # the most popular pair repeated across many files
  popular-equiv(popular-pairs([list: bl1, bl2, bl3, bl4, bl5]),
    tv(4, [list: pair("bb", "aa")])) is true
end
