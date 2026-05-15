
provide: j-nth end
# END HEADER

#| chaff: j-nth uses 1-based indexing instead of 0-based. |#

# CHAFF DIFFERENCE: uses 1-indexed access (get(n-1)).
fun j-nth<A>(jl :: JoinList<A>, n :: Number) -> A:
  join-list-to-list(jl).get(n - 1)
end
