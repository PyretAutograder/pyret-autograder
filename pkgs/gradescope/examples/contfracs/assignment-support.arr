provide: *, type * end

data Stream<T>:
  | lz-link(first :: T, rest :: (-> Stream<T>))
end

fun lz-first<A>(s :: Stream<A>) -> A:
  s.first
end

fun lz-rest<A>(s :: Stream<A>) -> Stream<A>:
  s.rest()
end

fun lz-cons<A>(f :: A, r :: Stream<A>) -> Stream<A>:
  lz-link(f, lam(): r end)
end

fun lz-map<A, B>(func :: (A -> B), s :: Stream<A>) -> Stream<B>:
  lz-link(func(lz-first(s)), lam(): lz-map(func, lz-rest(s)) end)
end

fun drop<T>(n :: Number, s :: Stream<T>) -> Stream<T>:
  doc: "Removes the first n elements from stream s."
  if n == 0:
    s
  else:
    drop(n - 1, lz-rest(s))
  end
end


