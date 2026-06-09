provide:
  data Tv-pair,
  data BookPair,
  count,
  lst-same-els,
  recommend-equiv,
end
provide-types *

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

fun count<A>(target :: A, a :: List<A>, eq-checker :: (A, A -> Boolean)) -> Number:
  doc: "counts quantity of target in a"
  a.foldl({(el, cnt): if eq-checker(el, target): cnt + 1 else: cnt end}, 0)
end

fun lst-same-els<A>(
    a :: List<A>,
    b :: List<A>,
    eq-checker :: (A, A -> Boolean))
  -> Boolean:
  doc: "checks whether two lists have the same elements in the same quantity"
  fun same-count(el, acc):
    acc and (count(el, a, eq-checker) == count(el, b, eq-checker))
  end
  (a.length() == b.length()) and a.foldl(same-count, true)
end

fun recommend-equiv<A>(
    t1 :: Tv-pair<Number, List<A>>,
    t2 :: Tv-pair<Number, List<A>>)
  -> Boolean:
  doc: "checks whether two recommendations are equivalent"
  (t1.tag == t2.tag) and lst-same-els(t1.value, t2.value, lam(x, y): x == y end)
end
