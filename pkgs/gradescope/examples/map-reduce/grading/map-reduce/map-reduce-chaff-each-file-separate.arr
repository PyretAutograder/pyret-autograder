
provide: map-reduce end
# END HEADER

#| chaff (mheller6, Aug 31, 2020):
    Runs map-reduce on each file separately then combines results. |#

# CHAFF DIFFERENCE: processes each file in isolation, missing cross-file grouping.
fun map-reduce<A, B, M, N, O>(
    input :: List<Tv-pair<A, B>>,
    mapper :: (Tv-pair<A, B> -> List<Tv-pair<M, N>>),
    reducer :: (Tv-pair<M, List<N>> -> Tv-pair<M, O>))
  -> List<Tv-pair<M, O>>:
  fun map-reduce-correct(shadow-input, shadow-mapper, shadow-reducer):
    mapped = for fold(acc from empty, input-pair from shadow-input):
      acc.append(shadow-mapper(input-pair))
    end
    grouped = group({(a :: Tv-pair<M, N>, b :: Tv-pair<M, N>): a.tag == b.tag}, mapped)
    for fold(answer from empty, grp :: List<Tv-pair<M, N>> from grouped):
      cases (List) grp:
        | empty => raise("the groups created by the group function cannot be empty")
        | link(first, _) =>
          reduced = shadow-reducer(tv(first.tag, map(_.value, grp)))
          link(reduced, answer)
      end
    end
  end
  for fold(acc from empty, file from input):
    acc + map-reduce-correct([list: file], mapper, reducer)
  end
end
