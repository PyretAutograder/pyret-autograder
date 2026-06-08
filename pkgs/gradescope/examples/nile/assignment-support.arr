
provide *
provide-types *

import equality as Eq
import length, all from lists

data File:
  | file(name :: String, content :: List<String>)
end

data BookPair:
  | pair(book1 :: String, book2 :: String)
    with:
    method _equals(
        self :: BookPair,
        other :: BookPair,
        equal-rec :: (Any, Any -> Eq.EqualityResult))
      -> Eq.EqualityResult:
      cases (BookPair) self:
        | pair(sb1, sb2) =>
          cases (BookPair) other:
            | pair(ob1, ob2) =>
              if ((Eq.is-Equal(equal-rec(sb1, ob1)) 
                    and Eq.is-Equal(equal-rec(sb2, ob2))) or
                  (Eq.is-Equal(equal-rec(sb1, ob2)) 
                    and Eq.is-Equal(equal-rec(sb2, ob1)))):
                Eq.Equal
              else:
                Eq.NotEqual("different books", self, other)
              end
          end
      end
    end
end


data Recommendation<A>:
  | recommendation(count :: Number, content :: List<A>)
    with:
    method _equals(
        self :: Recommendation<A>,
        other :: Recommendation<A>, 
        equal-rec :: (Any, Any -> Eq.EqualityResult))
      -> Eq.EqualityResult:

      fun names-to-set(names :: List<A>) -> sets.Set<A>:
        sets.list-to-list-set(names)
      end
      cases (Recommendation<A>) self:
        | recommendation(sc, scont) =>
          cases (Recommendation<A>) other:
            | recommendation(oc, ocont) =>
              if self.count <> other.count:
                Eq.NotEqual("inequal counts", self.count, other.count)
              else if not(self.content.length() == other.content.length()):
                Eq.NotEqual("inequal content length", 
                  self.content.length(), other.content.length())
              else:
                equal-rec(
                  names-to-set(self.content),
                  names-to-set(other.content))
              end
          end
      end
    end
end

# ---- validation predicates ----



fun list-has-no-dups(x :: List) -> Boolean:
  sets.list-to-list-set(x).size() == length(x)
end

fun is-valid-filename(x) -> Boolean:
  is-string(x)
end

fun is-valid-bookname(x) -> Boolean:
  is-string(x) and (string-length(x) > 0)
end

fun is-valid-filecontent(x) -> Boolean:
  is-List(x) and 
  (length(x) >= 2) and 
  all(is-valid-bookname, x) and 
  list-has-no-dups(x)
end

fun is-valid-file(x) -> Boolean:
  is-File(x) and is-valid-filename(x.name) and is-valid-filecontent(x.content)
end

fun is-valid-bookrecords(x) -> Boolean:
  is-List(x) and all(is-valid-file, x)
end

fun is-valid-rec-count(x) -> Boolean:
  is-number(x) and (x >= 0)
end

fun is-valid-rec-content(x) -> Boolean:
  is-List(x)
end

fun is-valid-rec(x) -> Boolean:
  is-Recommendation(x) and 
  (((x.count == 0) and (length(x.content) == 0)) or
    (((x.count > 0) and (length(x.content) > 0))))
end

fun is-valid-bookpair(x) -> Boolean:
  is-BookPair(x) and is-valid-bookname(x.book1) and is-valid-bookname(x.book2)
end

fun recommend-in-ok(x) -> Boolean:
  if not(is-tuple(x)):
    raise("Usage error: `overlap` takes multiple arguments, Quartermaster expects them as a single tuple")
  else:
    {title; book-records} = x # Can I check the length of the tuple?
    is-valid-bookname(title) and is-valid-bookrecords(book-records)
  end
end

fun recommend-out-ok(x) -> Boolean:
  is-valid-rec(x) and all(is-valid-bookname, x.content)
end

fun popular-pairs-in-ok(x) -> Boolean:
    ask:
    | (is-tuple(x)) then:
      {records; } = x # Can I check the length of the tuple?
      is-valid-bookrecords(records)
    | otherwise:
      is-valid-bookrecords(x)
  end
end

fun popular-pairs-out-ok(x) -> Boolean:
  is-valid-rec(x) and 
  all(is-valid-bookpair, x.content) and
  list-has-no-dups(x.content)
end
