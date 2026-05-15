
provide: j-first end
# END HEADER

#| chaff: j-first raises when the JoinList contains exactly one element. |#

# CHAFF DIFFERENCE: raises when j-first is called on a singleton JoinList.
fun j-first<A>(jl :: JoinList<A>) -> A:
  lst = join-list-to-list(jl)
  if lst.length() == 1:
    raise("one jl")
  else:
    lst.first
  end
end
