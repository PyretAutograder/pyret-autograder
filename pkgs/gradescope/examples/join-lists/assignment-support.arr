provide: *, type * end

import equality as EQ
import valueskeleton as VS

newtype MJL as MJLT
is-MJL = MJLT.test

type ManyJoinList<T> = MJL

data JoinList<T>:
  | empty-join-list
  | one(elt :: T)
  | many(mjl :: ManyJoinList<T>)
sharing:
  method _output(self :: JoinList<T>) -> VS.ValueSkeleton:
    lst = join-list-to-list(self)
    VS.vs-collection("join-list", lst.map(VS.vs-value))
  end,
  method length(self :: JoinList<T>) -> Number:
    cases (JoinList<T>) self:
      | empty-join-list => 0
      | one(_) => 1
      | many(mjl) => mjl.length()
    end
  end,
  method join(self :: JoinList<T>, other :: JoinList<T>) -> JoinList<T>:
    left = join-list-to-list(self)
    right = join-list-to-list(other)
    list-to-join-list(left + right)
  end
end

fun list-to-join-list<T>(lst :: List<T>) -> JoinList<T>:
  len = lst.length()
  cases (List<T>) lst:
    | empty => empty-join-list
    | link(f, r) =>
      cases (List<T>) r:
        | empty => one(f)
        | link(_, _) =>
          split = {():
            index = num-random(len - 2) + 1
            parts = lst.split-at(index)
            left = list-to-join-list(parts.prefix)
            right = list-to-join-list(parts.suffix)
            {left: left, right: right}
          }
          MJLT.brand({
              method _equals(
                  self :: ManyJoinList<T>,
                  other :: ManyJoinList<T>,
                  equal-rec :: (Any, Any -> EQ.EqualityResult)
                  ) -> EQ.EqualityResult:
                equal-rec(
                  join-list-to-list(many(self)),
                  join-list-to-list(many(other)))
              end,
              method rebalance-and-split-parallel<U, V, W>(
                  self,
                  lproc :: (JoinList<T> -> U),
                  rproc :: (JoinList<T> -> V),
                  comb :: (U, V -> W)
                  ) -> W:
                parts = split()
                comb(lproc(parts.left), rproc(parts.right))
              end,
              method rebalance-and-split<U>(
                  self,
                  comb :: (JoinList<T>, JoinList<T> -> U)
                  ) -> U:
                parts = split()
                comb(parts.left, parts.right)
              end,
              method length(self) -> Number:
                len
              end
            }) ^ many
      end
  end
end

fun join-list-to-list<T>(jl :: JoinList<T>) -> List<T>:
  cases (JoinList<T>) jl:
    | empty-join-list => empty
    | one(ele) => [list: ele]
    | many(mjl) => mjl.rebalance-and-split-parallel(
        join-list-to-list,
        join-list-to-list,
        _ + _)
  end
end

fun is-non-empty-jl<T>(jl :: JoinList<T>) -> Boolean:
  is-one(jl) or is-many(jl)
end

join-list = {
  make:  lam(arr): list.make(arr) ^ list-to-join-list end,
  make0: lam(): list.make0() ^ list-to-join-list end,
  make1: lam(a): list.make1(a) ^ list-to-join-list end,
  make2: lam(a, b): list.make2(a, b) ^ list-to-join-list end,
  make3: lam(a, b, c): list.make3(a, b, c) ^ list-to-join-list end,
  make4: lam(a, b, c, d): list.make4(a, b, c, d) ^ list-to-join-list end,
  make5: lam(a, b, c, d, e): list.make5(a, b, c, d, e) ^ list-to-join-list end,
}
