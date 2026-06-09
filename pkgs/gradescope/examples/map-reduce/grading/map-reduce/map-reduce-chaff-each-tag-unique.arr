# assigns unique tag names to each anagram
#
#Test Suites
# - anagrams-case-sensitive:: Checks that case is sensitive
# - anagrams-normal-cases:: Checks normal cases
#fail
# Don't change anything above this line

## A. Your map-reduce definition

fun contains-tag<A>(t :: A, pairs :: List<Tv-pair>) -> Boolean:
  doc: ```consumes a value and a list of pairs and tells whether the value 
       is a tag of one of the pairs.```
  fold(lam(a, b): a or b end, false, map(lam(p): p.tag == t end, pairs))
end

fun find-tag(t :: Any, pairs :: List<Tv-pair>, holder :: Number) -> Number:
  doc: ```returns the position of the first pair in the list of pairs that has
 the given string as its tag.```
  cases (List) pairs:
    |link(f, r) =>
      if f.tag == t:
        holder
      else:
        find-tag(t, r, 1 + holder)
      end
  end
end

fun get-values(t :: Any, pairs :: List<Tv-pair>) -> Any:
  doc: "returns the value of the first pair with the given string as its tag."
  pairs.get(find-tag(t, pairs, 0)).value
end

fun combine(mapped :: List<Tv-pair>, used :: List<Tv-pair>) -> List<Tv-pair>:
  doc: "Collects all values in a list of pairs with the same tag"
  cases (List) mapped:
    |empty => used
    |link(f, r) =>
      if contains-tag(f.tag, used):
        combine(r, used.set(find-tag(f.tag, used, 0), tv(f.tag, link(f.value, 
                get-values(f.tag, used)))))
      else:
        combine(r, link(tv(f.tag, [list: f.value]), used))
      end
  end
end

fun map-reduce(input :: List<Tv-pair>,
    mapper :: (Tv-pair -> List<Tv-pair>),
    reducer :: (Tv-pair -> Tv-pair)) -> List<Tv-pair>:
  doc:```consumes a list of tv pairs. applies mapper to each item of the list,
      then combines all resulting pairs with the same tag into a single tv pair 
      with a list as its value, then applies reducer to each of these pairs.```
  map(reducer, combine(fold(lam(x, y): x.append(y) end, empty, map(mapper, input)), empty))
end

### B. Your anagram implementation  
fun anagram-map(input :: Tv-pair<String, String>) 
  -> List<Tv-pair<String, String>>:
  doc:```consumes a tv pair consisting of a file name and a string
      returns a list of tv pairs each consisting of a word (as the value) 
      and an alphabetized version of the word (as the tag).```
  if input.value == "":
    empty
  else:
    map(lam(x): 
        tv(x, x)
        #There is no tag generation here
      end, string-split-all(input.value, " "))
  end
end


fun anagram-reduce(input :: Tv-pair<String, List<String>>) 
  -> Tv-pair<String, List<String>>:
  doc:"Removes duplicates"
  fun red-helper(values :: List<String>):
    cases(List<String>) values:
      | empty => empty
      | link(f,r) => 
        if r.member(f):
          red-helper(r)
        else:
          link(f, red-helper(r))
        end
    end
  end
  tv(input.tag, red-helper(input.value))
end



## C. Your Nile implementation
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
        if books.member(title):
          for map(book from books):
            tv(book, if book == title: 0 else: 1 end)
          end
        else:
          for map(book from books):
            tv(book, 0)
          end
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
      pair("Harry Potter", "Moby Dick")])|#
end
