provide:
  j-first, j-rest, j-length, j-nth, j-max, j-map, j-filter, j-reduce, j-sort
end

include file("submission/assignment-support.arr")

shadow is-non-empty-jl = {(x): true}

fun j-first<A>(jl :: JoinList<A>%(is-non-empty-jl)) -> A:
  join-list-to-list(jl).first
  where:
    1 is 1 # bogus test
end

fun j-rest<A>(jl :: JoinList<A>%(is-non-empty-jl)) -> JoinList<A>:
  join-list-to-list(jl).rest ^ list-to-join-list
  where:
    1 is 1 # bogus test
end

fun j-length<A>(jl :: JoinList<A>) -> Number:
  join-list-to-list(jl).length()
  where:
    1 is 1 # bogus test
end

fun j-nth<A>(jl :: JoinList<A>%(is-non-empty-jl), n :: Number) -> A:
  join-list-to-list(jl).get(n)
  where:
    1 is 1 # bogus test
end

fun j-max<A>(jl :: JoinList<A>%(is-non-empty-jl), cmp :: (A, A -> Boolean)) -> A:
  lst = join-list-to-list(jl)
  lst.foldl({(elt, acc): if cmp(elt, acc): elt else: acc end}, lst.first)
  where:
    1 is 1 # bogus test
end

fun j-map<A, B>(map-fun :: (A -> B), jl :: JoinList<A>) -> JoinList<B>:
  jl ^ join-list-to-list ^ map(map-fun, _) ^ list-to-join-list
  where:
    1 is 1 # bogus test
end

fun j-filter<A>(filter-fun :: (A -> Boolean), jl :: JoinList<A>) -> JoinList<A>:
  jl ^ join-list-to-list ^ filter(filter-fun, _) ^ list-to-join-list
  where:
    1 is 1 # bogus test
end

fun j-reduce<A>(reduce-func :: (A, A -> A), jl :: JoinList<A>%(is-non-empty-jl)) -> A:
  lst = join-list-to-list(jl)
  fold(reduce-func, lst.first, lst.rest)
  where:
    1 is 1 # bogus test
end

fun j-sort<A>(cmp-fun :: (A, A -> Boolean), jl :: JoinList<A>) -> JoinList<A>:
  eq-fun = {(a, b): not(cmp-fun(a, b)) and not(cmp-fun(b, a))}
  join-list-to-list(jl).sort-by(cmp-fun, eq-fun) ^ list-to-join-list
  where:
    1 is 1 # bogus test
end
