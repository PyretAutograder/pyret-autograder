provide:
  j-first, j-rest, j-length, j-nth, j-max, j-map, j-filter, j-reduce, j-sort,
end
# END HEADER

include file("submission/assignment-support.arr")
import all, any, each, reverse from lists

# ---- reference implementation ----
#| wheat
   (jchen345, Sep 6, 2021)
    Basic wheat; follows specs without additional features.
    Uses list functions.
|#


shadow is-non-empty-jl = {(x): true}
shadow is-join-list = {(x): true}

# Required Functions
# --------------------------------------------------------------------------------------------------
fun j-first<A>(jl :: JoinList<A>%(is-non-empty-jl)) -> A:
  doc: "Returns first element of jl"
  join-list-to-list(jl).first
  #|where:
  j-first(one(1)) is 1
  j-first(list-to-join-list([list: 1, 2, 3])) is 1
  j-first(list-to-join-list([list: "A", "B", "C"])) is "A"|#
end

fun j-rest<A>(jl :: JoinList<A>%(is-non-empty-jl)) -> JoinList<A>:
  doc: "Returns all but the first element of jl"
  join-list-to-list(jl).rest ^ list-to-join-list
  #|where:
  [list: 1] ^ list-to-join-list ^ j-rest is empty ^ list-to-join-list
  [list: 1, 2, 3, 4] ^ list-to-join-list ^ j-rest 
    is [list: 2, 3, 4] ^ list-to-join-list
  [list: 1, 2, 3, 4, 5, 6, 7] ^ list-to-join-list ^ j-rest 
    is [list: 2, 3, 4, 5, 6, 7] ^ list-to-join-list|#
end

fun j-length<A>(jl :: JoinList<A>) -> Number:
  doc: "Calculates the length of jl"
  join-list-to-list(jl).length()
  #|where:
  j-length(empty-join-list) is 0
  j-length(one(1)) is 1
  j-length(list-to-join-list([list: 1, 2])) is 2
  j-length(list-to-join-list([list: 1, 2, 3])) is 3
  j-length(list-to-join-list([list: "A", "B", "C", "D", "E", "F", "G"])) is 7|#
end

fun j-nth<A>(jl :: JoinList<A>%(is-non-empty-jl), n :: Number) -> A:
  doc: "Returns the nth element of jl (zero-indexed)"
  join-list-to-list(jl).get(n)
  #|where:
  j-nth(one(1), 0) is 1
  j-nth([list: 1, 2, 3, 4] ^ list-to-join-list, 0) is 1
  j-nth([list: 1, 2, 3, 4] ^ list-to-join-list, 1) is 2
  j-nth([list: 1, 2, 3, 4] ^ list-to-join-list, 2) is 3
  j-nth([list: 1, 2, 3, 4] ^ list-to-join-list, 3) is 4|#
end

fun j-max<A>(jl :: JoinList<A>%(is-non-empty-jl), 
    cmp :: (A, A -> Boolean)) -> A:
  doc: ```Consumes a JoinList and a comparator that consumes two values and 
       produces true if the first one is greater and produces the maximal 
       element in the JoinList```
  lst = join-list-to-list(jl)
  lst.foldl({(elt, acc): if cmp(elt, acc): elt else: acc end}, lst.first)
  #|where:
  j-max(one(1), lam(x, y): x > y end) is 1
  j-max(list-to-join-list([list: 1, 2, 3]), lam(x, y): x > y end) is 3
  j-max(list-to-join-list([list: 1, 1, 1, 1, 2, 3, 3]), lam(x, y): x > y end) is 3
  j-max(list-to-join-list([list: 1, 2, 3, 4, 5, 6, 7, 8]), lam(x, y): x > y end) is 8

  j-max(one(1), lam(x, y): x < y end) is 1
  j-max(list-to-join-list([list: 1, 2, 3]), lam(x, y): x < y end) is 1

  j-max(list-to-join-list([list: 1, 2, 3]), 
    lam(x, y): num-modulo(x, 5) < num-modulo(y, 5) end) is 1
  [list: 1, 11].member(j-max(list-to-join-list([list: 1, 2, 3, 4, 6, 7, 8, 9, 11]), 
      lam(x, y): num-modulo(x, 5) < num-modulo(y, 5) end)) is true

  j-max([list: "apple", "banana", "carrots"] ^ list-to-join-list, 
    lam(x, y): string-length(x) < string-length(y) end) is "apple"|#
end

fun j-map<A, B>(map-fun :: (A -> B), jl :: JoinList<A>) -> JoinList<B>:
  doc: ```consumes a JoinList and produdes the JoinList resulting from the 
       application of map-fun to the elements in jl```
  jl ^ join-list-to-list ^ map(map-fun, _) ^ list-to-join-list
  #|where:
  j-map(some, empty-join-list) is empty-join-list
  j-map(_ + 1, one(1)) is one(2)
  j-map(some, [list: 1, 2, 3, 4] ^ list-to-join-list)
    is [list: 1, 2, 3, 4].map(some) ^ list-to-join-list|#
end

fun j-filter<A>(filter-fun :: (A -> Boolean), jl :: JoinList<A>) -> JoinList<A>:
  doc: ```consumes a JoinList and produces a JoinList containing only those 
       elements for which the filter-fun produces true```
  jl ^ join-list-to-list ^ filter(filter-fun, _) ^ list-to-join-list
  #|where:
  j-filter(lam(x): x == 0 end, empty-join-list) is empty-join-list
  j-filter(lam(x): x == 0 end, one(0)) is one(0)
  j-filter(lam(x): x == 0 end, one(1)) is empty-join-list
  j-filter(lam(x): x == 0 end, list-to-join-list([list: 0, 1, 2, 3])) is one(0)
  j-filter(lam(x): string-length(x) > 5 end, empty-join-list) is empty-join-list
  j-filter(lam(x): string-length(x) > 5 end, one("Abcdef")) is one("Abcdef")
  j-filter(lam(x): string-length(x) > 5 end, one("A")) is empty-join-list
  j-filter(lam(x): string-length(x) > 5 end, 
    list-to-join-list([list: "Abcdef", "A", "111111", "10101"])) 
    is list-to-join-list([list: "Abcdef", "111111"])|#
end

fun j-sort<A>(cmp-fun :: (A, A -> Boolean), jl :: JoinList<A>) -> JoinList<A>:
  doc: ```sorts jl using cmp-fun. cmp-fun returns true when the first is greater.```
  eq-fun = {(a, b): not(cmp-fun(a, b)) and not(cmp-fun(b, a))}
  join-list-to-list(jl).sort-by(cmp-fun, eq-fun) ^ list-to-join-list
  #|where:
  # simple manipulations with conventional sorting
  j-sort(lam(x, y): x > y end, empty-join-list) is empty-join-list
  j-sort(lam(x, y): x > y end, one(1)) is one(1)
  j-sort(lam(x, y): x > y end, [list: 1, 2, 3, 4, 5] ^ list-to-join-list) is
  [list: 5, 4, 3, 2, 1] ^ list-to-join-list

  # larger numerical tests, conventional sorting
  j-sort(_ < _, range(0, 100) ^ lists.shuffle ^ list-to-join-list) 
    is range(0, 100) ^ list-to-join-list

  # modulus with equivalence classes
  j-sort(lam(x, y): num-modulo(x, 5) < num-modulo(y, 5) end, 
    [list: 1, 2, 3, 4, 5] ^ list-to-join-list) ^ join-list-to-list is [list: 5, 1, 2, 3, 4]
  j-sort(lam(x, y): num-modulo(x, 5) < num-modulo(y, 5) end, 
    [list: 1, 2, 3, 4, 5, 6] ^ list-to-join-list) ^ join-list-to-list is [list: 5, 6, 1, 2, 3, 4]
  j-sort(lam(x, y): num-modulo(x, 5) < num-modulo(y, 5) end, 
    [list: 6, 2, 3, 4, 5, 1] ^ list-to-join-list) ^ join-list-to-list is [list: 5, 1, 6, 2, 3, 4]

  # Not on numbers
  j-sort(lam(x, y): string-length(x) < string-length(y) end, 
    [list: "apple", "banana", "carrots"] ^ list-to-join-list) is 
  [list: "apple", "banana", "carrots"] ^ list-to-join-list|#
end

fun j-reduce<A>(reduce-func :: (A, A -> A), jl :: JoinList<A>%(is-non-empty-jl)) -> A:
  doc: ```Distributes an operator across a non-empty list. That is, given the elements
       e1, e2, ..., en in order, and operator op, computes the equivalent of
       e1 op e2 op ... op en.```
  lst = join-list-to-list(jl)
  fold(reduce-func, lst.first, lst.rest)
  #|where:
  j-reduce(_ + _, one(1)) is 1
  j-reduce(_ + _, [list: 1, 2, 3, 4] ^ list-to-join-list)
    is 10
  take-left = lam(x, y): x end # Always takes the left element
  j-reduce(take-left, [list: 1, 2, 3] ^ list-to-join-list) is 1
  j-reduce(take-left, [list: 1, 2, 3, 4] ^ list-to-join-list) is 1
  j-reduce(take-left, [list: 4, 3, 2, 1] ^ list-to-join-list) is 4

  # commutative, but not associative
  j-reduce(lam(x, y): (2 * x) + (2 * y) end, [list: 1, 2] ^ list-to-join-list) is 6
  # All results are a valid result
  results-assoc = repeat(45, true).map(lam(_): j-reduce(lam(x, y): (2 * x) + (2 * y) end, 
      [list: 1, 2, 3, 4] ^ list-to-join-list) end)
  results-assoc.all([list: 40, 44, 52, 58, 66].member(_)) is true
  results-minus = repeat(15, true).map(lam(_): j-reduce(_ - _, 
      [list: 1, 2, 3] ^ list-to-join-list) end)
  # All possible results
  results-minus.all([list: -4, 2].member(_)) is true|#
end

# ---- test fixtures, helpers, and checks (named by function) ----
# Data definition for testing with non built-in data
data Person:
  | person(name :: String, age :: Number)
end

# Reused testing lists
L1 = [list: 1]
L2 = [list: 4,3,9]
L3 = [list: 3,1,4,0,5,9]
L4 = [list: -2,4,7,1,9]
L5 = [list: 7,6,5,4,3,2,1]
L-alpha = [list: "a", "b", "c", "d", "e", "f"]
L-person = [list: person("Daphne", 1), person("Betty", 10), 
  person("Abby", 5), person("Daphne", 1)]

JL0 = list-to-join-list(empty)
JL1 = list-to-join-list(L1)
JL2 =  list-to-join-list(L2)
JL3 =  list-to-join-list(L3)
JL4 =  list-to-join-list(L4)
JL5 =  list-to-join-list(L5)
JLA = list-to-join-list(L-alpha)
JLP = list-to-join-list(L-person)

gt = lam(x :: Number, y :: Number): x > y end
lt = lam(x :: Number, y :: Number): x < y end
strcmp = lam(x :: String, y :: String):
  string-to-code-point(x) > string-to-code-point(y)
end
double = lam(x :: Number): x * 2 end
add-one = lam(x :: Number): x + 1 end
lt3 = lam(x :: Number): x < 3 end
gt3 = lam(x :: Number): x > 3 end
add = lam(x :: Number, y :: Number): x + y end
multiply = lam(x :: Number, y :: Number): x * y end
gt-person = lam(x :: Person, y :: Person): gt(x.age, y.age) end
add-one-person = lam(x :: Person): person(x.name, x.age + 1) end
lt3-person = lam(x :: Person): lt3(x.age) end

# Oracle
# --------------------------------------------------------------------------------------------------
max = 100




fun list-max(lst :: List<Number>%(is-link),
    cmp-fun :: (Number, Number -> Boolean)) -> Number:
  cases (List) lst:
    | empty => raise("Empty list")
    | link(f, r) => r.foldl(lam(a, b): 
          if cmp-fun(a, b):
            a
          else:
            b
          end
        end, f)
  end
end

num-tests = 20 #number of each test


# Hardcoded tests
# --------------------------------------------------------------------------------------------------

check "j-first": 
  j-first(JL1) is 1
  j-first(JL2) is 4
  j-first(JL3) is 3 
  j-first(JL4) is -2 
  j-first(JL5) is 7 
  j-first(JLA) is "a"
  j-first(JLP) is person("Daphne", 1)
end

check "j-rest":  
  j-rest(JL1) is list-to-join-list(L1.rest)
  j-rest(JL2) is list-to-join-list(L2.rest)
  j-rest(JL3) is list-to-join-list(L3.rest)
  j-rest(JL4) is list-to-join-list(L4.rest)
  j-rest(JL5) is list-to-join-list(L5.rest)
  j-rest(JLA) is list-to-join-list(L-alpha.rest)
  j-rest(JLP) is list-to-join-list(L-person.rest)
end

check "j-length":  
  j-length(JL0) is 0
  j-length(JL1) is 1
  j-length(JL2) is 3
  j-length(JL3) is 6
  j-length(JL4) is 5
  j-length(JL5) is 7
  j-length(JLA) is 6
  j-length(JLP) is 4
end

check "j-nth":
  j-nth(JL1, 0) is 1
  j-nth(JL2, 1) is 3
  j-nth(JL3, 2) is 4 
  j-nth(JL4, 3) is 1 
  j-nth(JL5, 4) is 3
  j-nth(JLA, 5) is "f"
  j-nth(JLP, 2) is person("Abby", 5)
end

check "j-max":
  j-max(JL1, gt) is 1
  j-max(JL2, gt) is 9
  j-max(JL3, gt) is 9
  j-max(JL4, gt) is 9
  j-max(JL5, gt) is 7
  j-max(JL4, lt) is -2
  j-max(JLA, strcmp) is "f"
  j-max(JLP, gt-person) is person("Betty", 10)
end

check "j-map":
  j-map(double, JL0) is empty-join-list
  j-map(double, JL1) is list-to-join-list(L1.map(double))
  j-map(double, JL2) is list-to-join-list(L2.map(double))
  j-map(double, JL3) is list-to-join-list(L3.map(double))
  j-map(double, JL4) is list-to-join-list(L4.map(double))
  j-map(double, JL5) is list-to-join-list(L5.map(double))
  j-map(lam(x): string-append(x, "g") end, JLA)
    is list-to-join-list(L-alpha.map(lam(x): string-append(x, "g") end))
  j-map(add-one-person, JLP) is list-to-join-list(L-person.map(add-one-person))
end

check "j-filter":
  j-filter(lt3, JL0) is empty-join-list
  j-filter(lt3, JL1) is list-to-join-list(L1.filter(lt3))
  j-filter(gt3, JL1) is list-to-join-list(L1.filter(gt3))
  j-filter(lt3, JL2) is list-to-join-list(L2.filter(lt3))
  j-filter(lt3, JL3) is list-to-join-list(L3.filter(lt3))
  j-filter(lt3, JL4) is list-to-join-list(L4.filter(lt3))
  j-filter(lt3, JL5) is list-to-join-list(L5.filter(lt3))
  j-filter(lam(x): x == "g" end, JLA) is empty-join-list
  j-filter(lam(x): x == "c" end, JLA) is list-to-join-list([list: "c"])
  j-filter(lt3-person, JLP) is list-to-join-list(L-person.filter(lt3-person))
end

check "j-sort":
  j-sort(gt, empty-join-list) is empty-join-list
  j-sort(lt, JL2) is list-to-join-list(L2.sort())
  j-sort(lt, JL3) is list-to-join-list(L3.sort())
  j-sort(lt, JL4) is list-to-join-list(L4.sort())
  j-sort(lt, JL5) is list-to-join-list(L5.sort())
  j-sort(gt, JL5) is list-to-join-list(L5.sort().reverse())
  j-sort(lam(x,y): strcmp(y, x) end, JLA) is JLA
  j-sort(lt, JL1) is list-to-join-list(L1.sort())
  j-sort(gt-person, JLP) is list-to-join-list([list: person("Betty", 10), person("Abby", 5), 
      person("Daphne", 1), person("Daphne", 1)])
  j-sort(lam(x, y): num-modulo(x, 5) < num-modulo(y, 5) end, 
    [list: 1, 2, 3, 4, 5] ^ list-to-join-list) ^ join-list-to-list is [list: 5, 1, 2, 3, 4]
  j-sort(lam(x, y): num-modulo(x, 5) < num-modulo(y, 5) end, 
    [list: 1, 2, 3, 4, 5, 6] ^ list-to-join-list) ^ join-list-to-list satisfies
  [list: [list: 5, 1, 6, 2, 3, 4], [list: 5, 6, 1, 2, 3, 4]].member
  j-sort(lam(x, y): num-modulo(x, 5) < num-modulo(y, 5) end, 
    [list: 6, 2, 3, 4, 5, 1] ^ list-to-join-list) ^ join-list-to-list satisfies
  [list: [list: 5, 1, 6, 2, 3, 4], [list: 5, 6, 1, 2, 3, 4]].member

end

check "j-reduce":
  j-reduce(add, JL2) is L2.foldl(add, 0)
  j-reduce(add, JL3) is L3.foldl(add, 0)
  j-reduce(add, JL4) is L4.foldl(add, 0)
  j-reduce(add, JL5) is L5.foldl(add, 0)
  j-reduce(add, JL1) is L1.foldl(add, 0)
  j-reduce(multiply, JL2) is L2.foldl(multiply, 1)
  j-reduce(multiply, JL3) is L3.foldl(multiply, 1)
  j-reduce(multiply, JL4) is L4.foldl(multiply, 1)
  j-reduce(multiply, JL5) is L5.foldl(multiply, 1)
  j-reduce(string-append, JLA) is "abcdef"
end
