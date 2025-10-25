fun foldl<A, B>(lst :: List<A>, f :: (B, A -> B), acc :: B) -> B:
  cases (List) lst:
    | empty => acc
    | link(first, rest) => foldl(rest, f, f(acc, first))
  end
end

fun foldr<A, B>(lst :: List<A>, f :: (B, A -> B), acc :: B) -> B:
  cases (List) lst:
    | empty => acc
    | link(first, rest) => f(foldr(rest, f, acc), first)
  end
end
