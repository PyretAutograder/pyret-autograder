# add all books regardless of whether the target book is included in rec
#
#Causes most recommend tests to fail:
# - recommend-edge-cases:: Checks edge cases
# - recommend-normal-cases:: Checks normal cases  

fun parse(str :: String, delim :: String) -> List:
  doc: "String -> List of String. Parses str into words by the delimeter delim. Words can be divided by any number of the delimeter"
  if string-length(str) < string-length(delim):
    empty
  else if string-substring(str,0,string-length(delim)) == delim:
    parse(string-substring(str,string-length(delim), string-length(str)), delim)
  else:
    split = string-split-at(str, delim)
    link(split.word, parse(split.rest, delim))
  end
  #|where:
  parse("hi there man", " ") is [list: "hi", "there", "man"]
  parse("", "b") is empty
  parse("   ", " ") is empty
  parse("  pyret  is   awesome", " ") is [list: "pyret", "is", "awesome"]|#
end

fun string-split-at(str :: String, delim :: String) 
  -> {word :: String, rest :: String}:
  doc: ```Returns an object with two fields called word and rest. Word is
       the substring from the beginning of str up to but not including the
       first substring of str that is delim. Rest is therest of the string
       including the delim substring.```
  if string-length(str) < string-length(delim):
    {word: str, rest: ""}
  else if string-substring(str, 0, string-length(delim)) == delim:
    {word: "", rest: str}
  else:
    recur = string-split-at(string-substring(str, 1, string-length(str)), delim)
    {word: string-substring(str,0,1) + recur.word, rest: recur.rest}
  end
end

fun group(pred :: (Any, Any -> Boolean), l :: List) -> List:
  doc: "pred is an equivalence relation on l. The function returns a list of equivalence classes of the elements of l under pred."
  cases(List) l:
    | empty => empty
    | link(first, rest) =>
      split = for fold(acc from {equal: empty, different: [list: ] }, elt from l):
        if pred(first, elt):
          {equal: link(elt, acc.equal), different: acc.different}
        else:
          {equal: acc.equal, different: link(elt, acc.different)}
        end
      end
      link(split.equal, group(pred, split.different))
  end
  #|where:
  group(lam(x, y): x.a == y.a end, [list: {a: 0, b: 0}, {a: 0, b: 1}, {a: 1, b: 0}, {a: 2, b: 3}, {a: 1, b: 3}]) is
  [list: [list: {a: 0, b: 1}, {a: 0, b: 0}], [list: {a: 1, b: 0}, {a: 1, b: 3}], [list: {a: 2, b: 3}]]
  group(lam(x, y): x == y end, [list: 1,2,3,2,1,3]) is [list: [list: 1,1], [list: 3,3], [list: 2,2]]
  group(lam(x, y): true end, [list: 1,2,3,2,1]) is [list: [list: 1,2,3,2,1]]
  group(lam(x, y): x == y end, empty) is empty|#
end
  

fun map-reduce(input :: List<Tv-pair>, mapper :: (Tv-pair -> List<Tv-pair>), reducer :: (Tv-pair -> Tv-pair)) -> List<Tv-pair>:
  all-mn-pairs = for fold(mn-list from empty, ab-pair from input):
    mn-list.append(mapper(ab-pair))
  end
  fun same-tag(p1 :: Tv-pair, p2 :: Tv-pair) -> Boolean: p1.tag == p2.tag end
  for fold(answer from empty, grp from group(same-tag, all-mn-pairs)):
    cases(List) grp:
      | empty => raise("the groups created by the group function cannot be empty")
      | link(first, _) => link(reducer(tv(first.tag, for map(elt from grp): elt.value end)), answer)
    end
  end
  #|where:
  map-reduce([list: tv("book1", "the man says hi"),
      tv("book2", "the woman says hi to the man"),
      tv("book3", "woman says hi")], wc-map, wc-reduce) is
  [list: tv("to", 1), tv("woman", 2), tv("says", 3),
    tv("man", 2), tv("hi", 3), tv("the", 3)]
  map-reduce(empty, wc-map, wc-reduce) is empty
  map-reduce([list: tv("book1", "a a a"), tv("book2", "b b")], wc-map, wc-reduce) is [list: tv("b", 2), tv("a", 3)]|#
end


#     _
#    / \   _ __   __ _  __ _ _ __ __ _ _ __ ___  ___
#   / _ \ | '_ \ / _` |/ _` | '__/ _` | '_ ` _ \/ __|
#  / ___ \| | | | (_| | (_| | | | (_| | | | | | \__ \
# /_/   \_\_| |_|\__,_|\__, |_|  \__,_|_| |_| |_|___/
#                      |___/


fun my-string-to-list(str :: String) -> List:
  doc: "converts a string into a list of its characters"
  if str == "":
    empty
  else:
    link(string-substring(str,0,1), my-string-to-list(string-substring(str,1, string-length(str))))
  end
  #|where:
  my-string-to-list("abc") is [list: "a", "b", "c"]
  my-string-to-list("") is empty
  my-string-to-list("haha") is [list: "h", "a", "h", "a"]|#
end


fun list-to-string(l :: List) -> String:
  doc: "concatenates the elements of the list which must be a list of strings"
  for fold(acc from "", elt from l):
    acc + elt
  end
  #|where:
  list-to-string([list: "h", "i", " ", "m", "a", "n"]) is "hi man"
  list-to-string(empty) is ""
  list-to-string([list: "hi", " ", "man"]) is "hi man"|#
end


fun alphabetize(str :: String) -> String:
  doc: "rearranges the letters of str into alphabetical order"
  list-to-string(my-string-to-list(str).sort())
  #|where:
  alphabetize("cba") is "abc"
  alphabetize("") is ""
  alphabetize("haha") is "aahh"|#
end


fun anagram-map(input :: Tv-pair<String, String>) -> List<Tv-pair>:
  cases(Tv-pair) input:
    | tv(_, contents) => for map(elt from parse(contents, " ")):
        tv(alphabetize(elt), elt)
      end
  end
  #|where:
  anagram-map(tv("words", "star rats tarts")) is [list: tv("arst", "star"), tv("arst", "rats"), tv("arstt", "tarts")]
  anagram-map(tv("words", "")) is empty
  anagram-map(tv("words", "hi")) is [list: tv("hi", "hi")]|#
end


fun anagram-reduce(input :: Tv-pair<String, List<String>>) -> Tv-pair<String, List<String>>:
  fun remove-duplicates(l :: List) -> List:
    cases(List) l:
      | empty => empty
      | link(first, rest) => link(first, remove-duplicates(for filter(elt from rest): elt <> first end))
    end
    #|where:
    nothing
    #remove-duplicates([list: 1,2,1,3,2,1]) is [list: 1,2,3]
    #remove-duplicates([list: "a", "b", "a", "b"]) is [list: "a", "b"]
    #remove-duplicates(empty) is empty|#
  end
  cases(Tv-pair) input:
    | tv(tag, contents) => tv(tag, remove-duplicates(contents))
  end
  #|where:
  anagram-reduce(tv("hi", [list: "hi", "hi", "ih", "ih"])) is tv("hi", [list: "hi", "ih"])
  anagram-reduce(tv("abc", [list: "abc", "cba", "bac", "bac", "cba", "abc"])) is tv("abc", [list: "abc", "cba", "bac"])
  anagram-reduce(tv("", empty)) is tv("", empty)|#
end


fun anagram(input :: List<Tv-pair<String, String>>) -> List<Tv-pair<String, List<String>>>:
  map-reduce(input, anagram-map, anagram-reduce)
  #|where:
  file1 = tv("file1", "internet-anagram-server i-rearrangement-servant")
  file2 = tv("file2", "dictionary elvis listen")
  file3 = tv("file3", "indicatory lives deirram silent")
  file4 = tv("file4", "admirer married slive")

  anagram([list: file1, file2, file3, file4]) is
  [list: tv("eilnst", [list: "silent", "listen"]), tv("adeimrr", [list: "deirram", "admirer", "married"]),
   tv("acdiinorty", [list: "indicatory", "dictionary"]),
    tv("eilsv", [list: "elvis", "lives", "slive"]),
    tv("--aaaeeeegimnnnrrrrsttv", [list: "i-rearrangement-servant", "internet-anagram-server"])]

  anagram([list: file2, file3]) is
  [list: tv("adeimrr", [list: "deirram"]), tv("eilsv", [list: "lives", "elvis"]), tv("eilnst", [list: "listen", "silent"]), tv("acdiinorty", [list: "indicatory", "dictionary"])]

  anagram([list: file2, file2]) is
  [list: tv("eilsv", [list: "elvis"]), tv("eilnst", [list: "listen"]), tv("acdiinorty", [list: "dictionary"])]|#
end

####NILE
#testing materials
#|RECS1 = tv("recs1", 
  [list: "Harry Potter", "Twilight", "Anna Karenina", "Moby Dick",
    "Surely You're Joking Mr Feynman"])
RECS2 = tv("recs2", 
    [list: "Moby Dick", "Harry Potter", "The Great Gatsby",
    "Surely You're Joking Mr Feynman"])
RECS3 = tv("recs3", 
  [list: "Frankenstein", "Hamlet", "Twilight", "Anna Karenina",
    "Surely You're Joking Mr Feynman"])
RECS4 = tv("recs4", 
  [list: "Surely You're Joking Mr Feynman", "Moby Dick", "Hamlet",
    "Harry Potter"])
BLIST1 = [list: RECS1, RECS2, RECS3, RECS4]
BLIST2 = [list: RECS2, RECS4]
   BLIST3 = [list: RECS1, RECS3]|#


fun rec-reduce<M>(recs :: Tv-pair<M, List<Number>>) 
  -> Tv-pair<M, Number>:
  cases(Tv-pair) recs:
    | tv(book, counts) => 
      tv(book, for fold(sum from 0, elt from counts): sum + elt end)
  end
  #|where:
  rec-reduce(tv("hi", [list: 1,2,3])) is tv("hi", 6)
  rec-reduce(tv("there", empty)) is tv("there", 0)
  rec-reduce(tv("man", [list: -3])) is tv("man", -3)|#
end


fun recommend(title :: String, 
    book-records :: List<Tv-pair<String, List<String>>>) 
  -> Tv-pair<Number, List<String>>:
  fun rec-map<A>(file :: Tv-pair<A, List<String>>) 
    -> List<Tv-pair<String, Number>>:
    doc: ```the mapper for recommend. the file's first field doesn't matter 
         and the second contains a list of distinct book names.
         It returns a list of tv-pairs of (book name, 1 if it was paired with
         title else 0)```
    cases(Tv-pair) file:
      | tv(_, books) =>
        ### SOURCE OF ERROR ###
        # missing this if: if books.member(title):
        for map(book from books):
          tv(book, if book == title: 0 else: 1 end)
        end
    end
  end

  raw-answers = map-reduce(book-records, rec-map, rec-reduce)
  max-number = for fold(max from 0, ex :: Tv-pair<String, Number>
      from raw-answers):
    if max < ex.value:
      ex.value
    else:
      max
    end
  end
  top-answers = for filter(ex :: Tv-pair<String, Number> from raw-answers):
    (ex.value == max-number) and (ex.value > 0)
  end
  tv(max-number, for map(ex from top-answers): ex.tag end)
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
  fun min(a :: String, b :: String): if a < b: a else: b end end
  fun max(a :: String, b :: String): if a < b: b else: a end end
  cases(List) lst:
    | empty => empty
    | link(first, rest) => 
      (for map(elt from rest): 
        pair(min(first, elt), max(first, elt)) end).append(combos(rest))
  end
  #|where:
  combos(empty) is empty
  combos([list: "hello", "world"]) is [list: pair("hello", "world")]
  combos([list: "world", "hello"]) is [list: pair("hello", "world")]
  combos([list: "c", "a", "b"]) is [list: pair("a", "c"), pair("b", "c"),
    pair("a", "b")]|#
end


fun popular-map(file :: Tv-pair<String, String>) 
  -> List<Tv-pair<String, Number>>:
  pairs = combos(file.value)
  for map(input from pairs):
    tv(input, 1)
  end
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
  popular-map(tv("just two", [list: "book1", "book2"])) is
  [list: tv(pair("book1", "book2"), 1)]|#
end


fun popular-pairs(book-records :: List<Tv-pair<String, String>>) 
  -> Tv-pair<Number, List<String>>:
  all-recs = map-reduce(book-records, popular-map, rec-reduce)
  top-score = for fold(max from 0, elt from all-recs):
    if max < elt.value:
      elt.value
    else:
      max
    end
  end
  best-pairs = for filter(elt from all-recs):
    elt.value == top-score
  end
  tv(top-score, for map(elt from best-pairs): elt.tag end)
  #|where:
  popular-pairs(BLIST1) 
    is tv(3, [list: pair("Moby Dick", "Surely You're Joking Mr Feynman"),
      pair("Harry Potter", "Surely You're Joking Mr Feynman"),
      pair("Harry Potter", "Moby Dick")])
  popular-pairs(BLIST2) 
    is tv(2, [list: pair("Harry Potter", "Surely You're Joking Mr Feynman"),
      pair("Moby Dick", "Surely You're Joking Mr Feynman"),
      pair("Harry Potter", "Moby Dick")])
  popular-pairs(BLIST3) 
    is tv(2, [list: pair("Anna Karenina", "Twilight"),
      pair("Surely You're Joking Mr Feynman", "Twilight"),
      pair("Anna Karenina", "Surely You're Joking Mr Feynman")])|#
end
