provide: j-first, j-rest, j-length, j-nth, j-max, j-map, j-filter, j-reduce, j-sort end
# END HEADER
#| wheat 2
   (jchen345, Sep 7, 2021)
   Search WHEAT DIFFERENCE for changes. 

   1) 'Strictly unstable sort'
   j-sort reverses list first then sorts 
   (checks that students are considering stable/unstable sorts)
   Uses list functions.

   2) Wheat checks for strict partial ordering in j-sort.
   If ordering is not well defined, raises error. 

   3) Checks for partial ordering in j-max.

   4) Returns nothing when empty is passed to first. 

   5) Returns empty-join-list when empty passed to rest.

   6) out of bound n for nth returns first element. 

   7) Returns last max instead of first max. 

   8) Reduces from right. 
|#

import lists as lists

shadow is-non-empty-jl = {(x): true}
shadow is-join-list = {(x): true}

# Required Functions
# --------------------------------------------------------------------------------------------------
fun j-first<A>(jl :: JoinList<A>%(is-non-empty-jl)) -> A:
  doc: "Returns first element of jl"
  cases (List<A>) join-list-to-list(jl):
    # WHEAT DIFFERENCE 4
    | empty => nothing
    | link(f, _) => f
  end
  #|where:
  j-first(one(1)) is 1
  j-first(list-to-join-list([list: 1, 2, 3])) is 1
  j-first(list-to-join-list([list: "A", "B", "C"])) is "A"|#
end

fun j-rest<A>(jl :: JoinList<A>%(is-non-empty-jl)) -> JoinList<A>:
  doc: "Returns all but the first element of jl"
  cases (List<A>) join-list-to-list(jl):
    # WHEAT DIFFERENCE 6
    | empty => [join-list: ]
    | link(_, r) => list-to-join-list(r)
  end
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
  # WHEAT DIFFERENCE 6
  if ((n < 0) or (n >= jl.length())):
    j-first(jl)
  else:
    join-list-to-list(jl).get(n)
  end
  #|where:
  j-nth(one(1), 0) is 1
  j-nth([list: 1, 2, 3, 4] ^ list-to-join-list, 0) is 1
  j-nth([list: 1, 2, 3, 4] ^ list-to-join-list, 1) is 2
  j-nth([list: 1, 2, 3, 4] ^ list-to-join-list, 2) is 3
  j-nth([list: 1, 2, 3, 4] ^ list-to-join-list, 3) is 4|#
end

fun j-max<A>(jl :: JoinList<A>%(is-non-empty-jl), 
    cmp :: (A, A -> Boolean)) -> A block:
  doc: ```Consumes a JoinList and a comparator that consumes two values and 
       produces true if the first one is greater and produces the maximal 
       element in the JoinList```
  # WHEAT DIFFERENCE 3
  if (j-length(jl) < 30) and not(strict-partial-ordering(cmp, jl ^ join-list-to-list)):
    raise("cmp is not well defined!")
  else:
    lst = join-list-to-list(jl)
    # WHEAT DIFFERENCE 7
    lst.foldr({(elt, acc): if cmp(elt, acc): elt else: acc end}, reverse(lst).first)
  end
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

fun strict-partial-ordering<A>(cmp-fun :: (A, A -> Boolean), lst :: List<A>) -> Boolean:
  doc: "Determines whether cmp-fun is a well-defined relation imposing a strict total ordering."
  irreflexive(cmp-fun, lst) and transitive(cmp-fun, lst)
  #|where:
  strict-partial-ordering({(a, b): a < (2 * b)}, [list: 1, 2, 3, 4, 5]) is false|#
end

fun irreflexive<A>(cmp-fun :: (A, A -> Boolean), lst :: List<A>) -> Boolean:
  doc: ```Determines whether cmp-fun is irreflexive. That is, a > a is invalid.```
  for all(a from lst):
    not(cmp-fun(a, a))
  end
end

fun transitive<A>(cmp-fun :: (A, A -> Boolean), lst :: List<A>) -> Boolean:
  doc: ```Determines whether cmp-fun is transitive. If a > b and b > c, then a > c.```
  for all(a from lst):
    for all(b from lst):
      for all(c from lst):
        if cmp-fun(a, b) and cmp-fun(b, c):
          cmp-fun(a, c)
        else:
          true
        end
      end
    end
  end
end

fun j-sort<A>(cmp-fun :: (A, A -> Boolean), jl :: JoinList<A>) -> JoinList<A>:
  doc: ```sorts jl using cmp-fun. cmp-fun returns true when the first is greater.```
  # WHEAT DIFFERENCE 2
  if (j-length(jl) < 30) and not(strict-partial-ordering(cmp-fun, jl ^ join-list-to-list)):
    raise("cmp-fun is not well defined!")
  else:
    eq-fun = {(a, b): not(cmp-fun(a, b)) and not(cmp-fun(b, a))}
    # WHEAT DIFFERENCE 1
    join-list-to-list(jl).reverse().sort-by(cmp-fun, eq-fun) ^ list-to-join-list
  end
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
  # WHEAT DIFFERENCE
  j-sort(lam(x, y): num-modulo(x, 5) < num-modulo(y, 5) end, 
    [list: 1, 2, 3, 4, 5, 6] ^ list-to-join-list) ^ join-list-to-list is [list: 5, 1, 6, 2, 3, 4]
  j-sort(lam(x, y): num-modulo(x, 5) < num-modulo(y, 5) end, 
    [list: 6, 2, 3, 4, 5, 1] ^ list-to-join-list) ^ join-list-to-list is [list: 5, 6, 1, 2, 3, 4]

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
  # WHEAT DIFFERENCE 8
  lists.foldr({(a, b): reduce-func(b, a)}, lst.last(), lst.reverse().rest.reverse())
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
  # All results are valid results
  for each(_ from range(0, 45)):
    j-reduce(
      lam(x, y): 2 * (x + y) end, 
      [list: 1, 2, 3, 4] ^ list-to-join-list) satisfies [list: 40, 44, 52, 58, 66].member
  end
  results-minus = repeat(15, true).map(
    lam(_): 
      j-reduce(_ - _, [list: 1, 2, 3] ^ list-to-join-list) 
    end)
  # All possible results
  results-minus.all([list: -4, 2].member) is true|#
end
