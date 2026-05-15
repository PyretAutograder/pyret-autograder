
provide: j-reduce end
# END HEADER

#| chaff: j-reduce processes elements in reverse order. |#

# CHAFF DIFFERENCE: reduces in reverse element order.
fun j-reduce<A>(reduce-func :: (A, A -> A), jl :: JoinList<A>) -> A:
  lst = join-list-to-list(jl).reverse()
  fold(reduce-func, lst.first, lst.rest)
end
