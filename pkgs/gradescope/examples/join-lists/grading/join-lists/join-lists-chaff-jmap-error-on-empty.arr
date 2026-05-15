
provide: j-map end
# END HEADER

#| chaff: j-map raises on an empty JoinList. |#

# CHAFF DIFFERENCE: raises when given an empty JoinList.
fun j-map<A, B>(map-fun :: (A -> B), jl :: JoinList<A>) -> JoinList<B>:
  lst = join-list-to-list(jl)
  cases (List<A>) lst:
    | empty => raise("Empty jl")
    | link(_, _) => map(map-fun, lst) ^ list-to-join-list
  end
end
