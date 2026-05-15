
provide: j-first, j-rest, j-length, j-nth, j-max, j-map, j-filter, j-reduce, j-sort end
# END HEADER
#| wheat 2 (jchen345, Sep 7, 2021):
    1) j-sort reverses list first then sorts (unstable sort)
    2) j-sort raises if cmp defines non-strict ordering
    3) j-max raises if cmp is not well defined
    4) j-first returns nothing on empty
    5) j-rest returns empty-join-list on empty
    6) j-nth returns first element for out-of-bounds n
    7) j-max returns last max instead of first
    8) j-reduce reduces from right
    Search WHEAT DIFFERENCE for changes. |#

fun j-first<A>(jl :: JoinList<A>) -> A:
  # WHEAT DIFFERENCE 4: returns nothing on empty
  cases (List<A>) join-list-to-list(jl):
    | empty => nothing
    | link(f, _) => f
  end
end

fun j-rest<A>(jl :: JoinList<A>) -> JoinList<A>:
  # WHEAT DIFFERENCE 5: returns empty-join-list on empty
  cases (List<A>) join-list-to-list(jl):
    | empty => [join-list: ]
    | link(_, r) => list-to-join-list(r)
  end
end

fun j-length<A>(jl :: JoinList<A>) -> Number:
  join-list-to-list(jl).length()
end

fun j-nth<A>(jl :: JoinList<A>, n :: Number) -> A:
  # WHEAT DIFFERENCE 6: returns first element for out-of-bounds n
  if (n < 0) or (n >= jl.length()):
    join-list-to-list(jl).first
  else:
    join-list-to-list(jl).get(n)
  end
end

fun j-max<A>(jl :: JoinList<A>, cmp :: (A, A -> Boolean)) -> A block:
  # WHEAT DIFFERENCE 3: raises if cmp is not well defined (on small lists)
  fun irreflexive(f, lst):
    for lists.all(a from lst): not(f(a, a)) end
  end
  fun transitive(f, lst):
    for lists.all(a from lst):
      for lists.all(b from lst):
        for lists.all(c from lst):
          if f(a, b) and f(b, c): f(a, c) else: true end
        end
      end
    end
  end
  lst = join-list-to-list(jl)
  when (lst.length() < 30) and not(irreflexive(cmp, lst) and transitive(cmp, lst)):
    raise("cmp is not well defined!")
  end
  # WHEAT DIFFERENCE 7: returns last max instead of first
  lst.foldr({(elt, acc): if cmp(elt, acc): elt else: acc end}, lst.reverse().first)
end

fun j-map<A, B>(map-fun :: (A -> B), jl :: JoinList<A>) -> JoinList<B>:
  jl ^ join-list-to-list ^ map(map-fun, _) ^ list-to-join-list
end

fun j-filter<A>(filter-fun :: (A -> Boolean), jl :: JoinList<A>) -> JoinList<A>:
  jl ^ join-list-to-list ^ filter(filter-fun, _) ^ list-to-join-list
end

fun j-reduce<A>(reduce-func :: (A, A -> A), jl :: JoinList<A>) -> A:
  # WHEAT DIFFERENCE 8: reduces from right
  lst-rev = join-list-to-list(jl).reverse()
  fold(reduce-func, lst-rev.first, lst-rev.rest)
end

fun j-sort<A>(cmp-fun :: (A, A -> Boolean), jl :: JoinList<A>) -> JoinList<A> block:
  # WHEAT DIFFERENCE 2: raises if cmp is not well defined (on small lists)
  fun irreflexive(f, lst):
    for lists.all(a from lst): not(f(a, a)) end
  end
  fun transitive(f, lst):
    for lists.all(a from lst):
      for lists.all(b from lst):
        for lists.all(c from lst):
          if f(a, b) and f(b, c): f(a, c) else: true end
        end
      end
    end
  end
  lst = join-list-to-list(jl)
  when (lst.length() < 30) and not(irreflexive(cmp-fun, lst) and transitive(cmp-fun, lst)):
    raise("cmp-fun is not well defined!")
  end
  eq-fun = {(a, b): not(cmp-fun(a, b)) and not(cmp-fun(b, a))}
  # WHEAT DIFFERENCE 1: reverses list first (unstable sort)
  lst.reverse().sort-by(cmp-fun, eq-fun) ^ list-to-join-list
end
