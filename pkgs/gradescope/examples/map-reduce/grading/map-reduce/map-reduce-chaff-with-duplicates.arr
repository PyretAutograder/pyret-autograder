#| chaff (mheller6, Aug 31, 2020):
    anagram-reduce function does not do anything, leaving you with possible duplicate anagrams

    Test Suites
      - anagrams-normal-cases:: Checks normal cases
      - anagrams-duplicate-values:: Checks that there are no duplicate tv values in the list fail
   
    Search CHAFF DIFFERENCE for source of error
|#

fun parse(str :: String, delim :: String) -> List<String>:
  doc: ```Parses str into words separated by the delimeter 
       delim. Words can be divided by any number of the delimeter```
  filter({(word): not(word == "")}, string-split-all(str, delim))
  #|where:
  parse("hi there man", " ") is [list: "hi", "there", "man"]
  parse("", "b") is empty
  parse("   ", " ") is empty
  parse("  pyret  is   awesome", " ") is [list: "pyret", "is", "awesome"]|#
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
  #|where:
  group(lam(x, y): true end, [list: 1,2,3,2,1]) is [list: [list: 1,2,3,2,1]]
  group(lam(x, y): x == y end, empty) is empty|#
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
  #|where:
  map-reduce(empty, wc-map, wc-reduce) is empty
  map-reduce([list: tv("book1", "a a a"), tv("book2", "b b")], wc-map, 
    wc-reduce) is [list: tv("b", 2), tv("a", 3)]|#
end


#     _
#    / \   _ __   __ _  __ _ _ __ __ _ _ __ ___  ___
#   / _ \ | '_ \ / _` |/ _` | '__/ _` | '_ ` _ \/ __|
#  / ___ \| | | | (_| | (_| | | | (_| | | | | | \__ \
# /_/   \_\_| |_|\__,_|\__, |_|  \__,_|_| |_| |_|___/
#                      |___/

fun list-to-string(l :: List<String>) -> String:
  doc: "concatenates the elements of the list which must be a list of strings"
  fold(_ + _, "", l)
  #|where:
  list-to-string([list: "h", "i", " ", "m", "a", "n"]) is "hi man"
  list-to-string(empty) is ""
  list-to-string([list: "hi", " ", "man"]) is "hi man"|#
end


fun alphabetize(str :: String) -> String:
  doc: "rearranges the letters of str into alphabetical order"
  list-to-string(string-explode(str).sort())
  #|where:
  alphabetize("cba") is "abc"
  alphabetize("") is ""
  alphabetize("haha") is "aahh"|#
end


fun anagram-map(input :: Tv-pair<String, String>) -> List<Tv-pair<String, String>>:
  words = parse(input.value, " ")
  map({(word): tv(alphabetize(word), word)}, words)
  #|where:
  anagram-map(tv("words", "star rats tarts")) is 
  [list: tv("arst", "star"), tv("arst", "rats"), tv("arstt", "tarts")]
  anagram-map(tv("words", "")) is empty
  anagram-map(tv("words", "hi")) is [list: tv("hi", "hi")]|#
end


fun anagram-reduce(input :: Tv-pair<String, List<String>>) -> Tv-pair<String, List<String>>:
  # CHAFF DIFFERENCE
  input
  #|where:
  anagram-reduce(tv("hi", [list: "hi", "hi", "ih", "ih"])) 
    is tv("hi", [list: "hi", "ih"])
  anagram-reduce(tv("", empty)) is tv("", empty)|#
end


fun anagram(input :: List<Tv-pair<String, String>>) -> List<Tv-pair<String, List<String>>>:
  map-reduce(input, anagram-map, anagram-reduce)
end


#  _   _ _ _
# | \ | (_) | ___
# |  \| | | |/ _ \
# | |\  | | |  __/
# |_| \_|_|_|\___|


#testing materials
#|RECS1 = tv("recs1", [list: "Harry Potter", "Twilight", "Anna Karenina", "Moby Dick",
    "Surely You're Joking Mr Feynman"])
RECS2 = tv("recs2", 
  [list: "Moby Dick", "Harry Potter", "The Great Gatsby", "Surely You're Joking Mr Feynman"])
RECS3 = tv("recs3", 
  [list: "Frankenstein", "Hamlet", "Twilight", "Anna Karenina", "Surely You're Joking Mr Feynman"])
RECS4 = tv("recs4", 
  [list: "Surely You're Joking Mr Feynman", "Moby Dick", "Hamlet", "Harry Potter"])
BLIST1 = [list: RECS1, RECS2, RECS3, RECS4]
BLIST2 = [list: RECS2, RECS4]
BLIST3 = [list: RECS1, RECS3]|#

fun max-by-val<A>(pairs :: List<Tv-pair<A, Number>>) -> Tv-pair<Number, List<A>>:
  max-val = fold(num-max, 0, map(_.value, pairs))
  shadow pairs = filter({(p): p.value == max-val}, pairs)
  tv(max-val, map(_.tag, pairs))
end

fun rec-reduce<M>(recs :: Tv-pair<M, List<Number>>) -> Tv-pair<M, Number>:
  tv(recs.tag, fold(_ + _, 0, recs.value))
  #|where:
  rec-reduce(tv("hi", [list: 1,2,3])) is tv("hi", 6)
  rec-reduce(tv("there", empty)) is tv("there", 0)
  rec-reduce(tv("man", [list: -3])) is tv("man", -3)|#
end

fun recommend(title :: String, book-records :: List<Tv-pair<String, List<String>>>) 
  -> Tv-pair<Number, List<String>>:
  fun rec-map<A>(file :: Tv-pair<A, List<String>>) 
    -> List<Tv-pair<String, Number>>:
    doc: ```the mapper for recommend. the file's first field doesn't matter 
         and the second contains a list of distinct book names.
         It returns a list of tv-pairs of (book name, 1 if it was paired with
         title else 0)```
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
  #|where:
  recommend("Harry Potter", BLIST1) 
    is tv(3, [list: "Surely You're Joking Mr Feynman", "Moby Dick"])
  recommend("Surely You're Joking Mr Feynman", BLIST1) 
    is tv(3, [list: "Moby Dick", "Harry Potter"])
  recommend("Moby Dick", BLIST1) 
    is tv(3, [list: "Surely You're Joking Mr Feynman", "Harry Potter"])
  recommend("Hamlet", BLIST1) 
    is tv(2, [list: "Surely You're Joking Mr Feynman"])|#
end


fun combos(lst :: List<String>) -> List<BookPair>:
  fun min(a :: String, b :: String) -> String: if a < b: a else: b end end
  fun max(a :: String, b :: String) -> String: if a < b: b else: a end end
  
  cases(List) lst:
    | empty => empty
    | link(first, rest) => map({(elt): pair(min(first, elt), max(first, elt))}, rest)
        .append(combos(rest))
  end
  #|where:
  combos(empty) is empty
  combos([list: "hello", "world"]) is [list: pair("hello", "world")]
  combos([list: "world", "hello"]) is [list: pair("hello", "world")]
  combos([list: "c", "a", "b"]) is [list: pair("a", "c"), pair("b", "c"), pair("a", "b")]|#
end


fun popular-map(file :: Tv-pair<String, List<String>>) -> List<Tv-pair<BookPair, Number>>:
  map(tv(_, 1), combos(file.value))
  #|where:
  popular-map(RECS1) is [list: tv(pair("Harry Potter", "Twilight"), 1),
    tv(pair("Anna Karenina", "Harry Potter"), 1),
    tv(pair("Harry Potter", "Moby Dick"), 1),
    tv(pair("Harry Potter", "Surely You're Joking Mr Feynman"), 1),
    tv(pair("Anna Karenina", "Twilight"), 1),
    tv(pair("Moby Dick", "Twilight"), 1),
    tv(pair("Surely You're Joking Mr Feynman", "Twilight"), 1),
    tv(pair("Anna Karenina", "Moby Dick"), 1),
    tv(pair("Anna Karenina", "Surely You're Joking Mr Feynman"), 1),
    tv(pair("Moby Dick", "Surely You're Joking Mr Feynman"), 1)]
  popular-map(tv("empty", empty)) is empty
  popular-map(tv("just two", [list: "book1", "book2"])) is [list: tv(pair("book1", "book2"), 1)]|#
end


fun popular-pairs(book-records :: List<Tv-pair<String, List<String>>>)
  -> Tv-pair<Number, List<BookPair>>:
  max-by-val(map-reduce(book-records, popular-map, rec-reduce))
  #|where:
  popular-pairs(BLIST1) 
    is tv(3, [list: pair("Moby Dick", "Surely You're Joking Mr Feynman"),
      pair("Harry Potter", "Surely You're Joking Mr Feynman"),
      pair("Harry Potter", "Moby Dick")])
  popular-pairs(BLIST2) 
    is tv(2, [list: pair("Harry Potter", "Surely You're Joking Mr Feynman"),
      pair("Moby Dick", "Surely You're Joking Mr Feynman"),
      pair("Harry Potter", "Moby Dick")])|#
end
