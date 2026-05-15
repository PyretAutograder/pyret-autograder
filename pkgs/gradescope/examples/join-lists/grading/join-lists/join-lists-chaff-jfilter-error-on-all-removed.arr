
provide: j-filter end
# END HEADER

#| chaff: j-filter raises when all elements are removed from a non-empty list. |#

# CHAFF DIFFERENCE: raises when all elements are removed.
fun j-filter<A>(filter-fun :: (A -> Boolean), jl :: JoinList<A>) -> JoinList<A> block:
  out = jl ^ join-list-to-list ^ filter(filter-fun, _) ^ list-to-join-list
  when (jl.length() > 0) and (out.length() == 0):
    raise("removed all elements")
  end
  out
end
