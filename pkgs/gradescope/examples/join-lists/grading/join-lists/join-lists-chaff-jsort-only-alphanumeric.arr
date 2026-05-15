
provide: j-sort end
# END HEADER

#| chaff: j-sort raises for non-alphanumeric (non-String, non-Number) inputs. |#

# CHAFF DIFFERENCE: raises for non-alphanumeric input.
fun j-sort<A>(cmp-fun :: (A, A -> Boolean), jl :: JoinList<A>) -> JoinList<A> block:
  when (jl.length() > 0) and not(is-string(j-first(jl)) or is-number(j-first(jl))):
    raise("non-alphanumeric input to j-sort")
  end
  eq-fun = {(a, b): not(cmp-fun(a, b)) and not(cmp-fun(b, a))}
  join-list-to-list(jl).sort-by(cmp-fun, eq-fun) ^ list-to-join-list
end
