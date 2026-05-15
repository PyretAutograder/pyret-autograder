
provide: j-first, j-rest, j-length, j-nth, j-max, j-map, j-filter, j-reduce, j-sort end
# END HEADER
#| wheat (jchen345, Sep 6, 2021):
    Basic wheat; follows specs without additional features. |#


fun j-first<A>(jl :: JoinList<A>) -> A:
  join-list-to-list(jl).first
end

fun j-rest<A>(jl :: JoinList<A>) -> JoinList<A>:
  join-list-to-list(jl).rest ^ list-to-join-list
end

fun j-length<A>(jl :: JoinList<A>) -> Number:
  join-list-to-list(jl).length()
end

fun j-nth<A>(jl :: JoinList<A>, n :: Number) -> A:
  join-list-to-list(jl).get(n)
end

fun j-max<A>(jl :: JoinList<A>, cmp :: (A, A -> Boolean)) -> A:
  lst = join-list-to-list(jl)
  lst.foldl({(elt, acc): if cmp(elt, acc): elt else: acc end}, lst.first)
end

fun j-map<A, B>(map-fun :: (A -> B), jl :: JoinList<A>) -> JoinList<B>:
  jl ^ join-list-to-list ^ map(map-fun, _) ^ list-to-join-list
end

fun j-filter<A>(filter-fun :: (A -> Boolean), jl :: JoinList<A>) -> JoinList<A>:
  jl ^ join-list-to-list ^ filter(filter-fun, _) ^ list-to-join-list
end

fun j-reduce<A>(reduce-func :: (A, A -> A), jl :: JoinList<A>) -> A:
  lst = join-list-to-list(jl)
  fold(reduce-func, lst.first, lst.rest)
end

fun j-sort<A>(cmp-fun :: (A, A -> Boolean), jl :: JoinList<A>) -> JoinList<A>:
  eq-fun = {(a, b): not(cmp-fun(a, b)) and not(cmp-fun(b, a))}
  join-list-to-list(jl).sort-by(cmp-fun, eq-fun) ^ list-to-join-list
end
