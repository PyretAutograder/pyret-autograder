
provide: j-sort end
# END HEADER

#| chaff: j-sort raises when two distinct elements compare as equal under cmp-fun. |#

# CHAFF DIFFERENCE: raises when distinct elements are considered equal by cmp-fun.
fun j-sort<A>(cmp-fun :: (A, A -> Boolean), jl :: JoinList<A>) -> JoinList<A>:
  lst = jl ^ join-list-to-list
  has-equal = block:
    for any(elt1 from lst):
      for any(elt2 from lst):
        not(elt1 == elt2) and not(cmp-fun(elt1, elt2) or cmp-fun(elt2, elt1))
      end
    end
  end
  if has-equal:
    raise("Elements are equal using cmp-fun")
  else:
    eq-fun = {(a, b): not(cmp-fun(a, b)) and not(cmp-fun(b, a))}
    lst.sort-by(cmp-fun, eq-fun) ^ list-to-join-list
  end
end
