provide: *, type * end

import equality as E

data Tv-pair<A, B>:
  | tv(tag :: A, value :: B)
end

data BookPair:
  | pair(book1 :: String, book2 :: String)
    with:
    method _equals(
        self :: BookPair,
        other :: BookPair,
        equal-rec :: (Any, Any -> E.EqualityResult))
      -> E.EqualityResult:
      cases (BookPair) self:
        | pair(sb1, sb2) =>
          cases (BookPair) other:
            | pair(ob1, ob2) =>
              if ((E.is-Equal(equal-rec(sb1, ob1))
                    and E.is-Equal(equal-rec(sb2, ob2))) or
                  (E.is-Equal(equal-rec(sb1, ob2))
                    and E.is-Equal(equal-rec(sb2, ob1)))):
                E.Equal
              else:
                E.NotEqual("different books", self, other)
              end
          end
      end
    end
end

fun parse(str :: String, delim :: String) -> List<String>:
  filter({(word): not(word == "")}, string-split-all(str, delim))
end

fun wc-map(file :: Tv-pair<String, String>) -> List<Tv-pair<String, Number>>:
  cases(Tv-pair) file:
    | tv(_, contents) => for map(word from parse(contents, " ")):
        tv(word, 1)
      end
  end
end

fun wc-reduce(word-counts :: Tv-pair<String, List<Number>>) -> Tv-pair<String, Number>:
  cases(Tv-pair) word-counts:
    | tv(word, counts) => tv(word, counts.length())
  end
end

fun count<A>(target :: A, a :: List<A>, eq-checker :: (A, A -> Boolean)) -> Number:
  a.foldl({(el, cnt): if eq-checker(el, target): cnt + 1 else: cnt end}, 0)
end

fun lst-same-els<A>(
    a :: List<A>,
    b :: List<A>,
    eq-checker :: (A, A -> Boolean))
  -> Boolean:
  fun same-count(el, acc):
    acc and (count(el, a, eq-checker) == count(el, b, eq-checker))
  end
  (a.length() == b.length()) and a.foldl(same-count, true)
end

fun recommend-equiv<A>(
    t1 :: Tv-pair<Number, List<A>>,
    t2 :: Tv-pair<Number, List<A>>)
  -> Boolean:
  (t1.tag == t2.tag) and lst-same-els(t1.value, t2.value, lam(x, y): x == y end)
end

####################################
######  Shared implementation  #####
####################################

fun group<A>(pred :: (A, A -> Boolean), l :: List<A>) -> List<List<A>>:
  cases(List) l:
    | empty => empty
    | link(first, rest) =>
      split = partition(pred(first, _), l)
      link(split.is-true, group(pred, split.is-false))
  end
end

fun list-to-string(l :: List<String>) -> String:
  fold(_ + _, "", l)
end

fun alphabetize(str :: String) -> String:
  list-to-string(string-explode(str).sort())
end

fun max-by-val<A>(pairs :: List<Tv-pair<A, Number>>) -> Tv-pair<Number, List<A>>:
  max-val = fold(num-max, 0, map(_.value, pairs))
  shadow pairs = filter({(p): p.value == max-val}, pairs)
  tv(max-val, map(_.tag, pairs))
end

fun rec-reduce<M>(recs :: Tv-pair<M, List<Number>>) -> Tv-pair<M, Number>:
  tv(recs.tag, fold(_ + _, 0, recs.value))
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
