
provide: j-max end
# END HEADER

#| chaff: j-max raises for non-alphanumeric (non-String, non-Number) inputs. |#

# CHAFF DIFFERENCE: raises for non-alphanumeric input.
fun j-max<A>(jl :: JoinList<A>, cmp :: (A, A -> Boolean)) -> A block:
  when (jl.length() > 0) and not(is-string(j-first(jl)) or is-number(j-first(jl))):
    raise("non-alphanumeric input to j-max")
  end
  lst = join-list-to-list(jl)
  lst.foldl({(elt, acc): if cmp(elt, acc): elt else: acc end}, lst.first)
end
