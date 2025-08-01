include file("../src/core.arr")
include file("../src/utils.arr")

import lists as L
import sets as S
import string-dict as SD

data ExBlockReason:
  | invalid
end

fun mk-node(id :: Id, deps :: List<Id>, shadow runner):
  node(id, deps, runner, none)
end

fun runner(val):
  lam():
    {val; none}
  end
end

fun res(outcome):
  executed(outcome, none, none)
end

fun skip(id):
  skipped(id, none)
end


check "execute":
  execute(empty) is [SD.string-dict:]

  single = [list: mk-node("1", [list:], runner(emit(1)))]
  execute(single) is [SD.string-dict: "1", res(emit(1))]

  simple_dep = [list: mk-node("pass_guard", [list:], runner(noop)),
                      mk-node("has_dep", [list: "pass_guard"], runner(emit(1)))]
  execute(simple_dep) is [SD.string-dict: "pass_guard", res(noop), "has_dep", res(emit(1))]

  blocking_simple_dep = [list: mk-node("block_guard", [list:], runner(block(invalid))),
                               mk-node("has_dep", [list: "block_guard"], runner(emit(1)))]
  execute(blocking_simple_dep) is [SD.string-dict: "block_guard", res(block(invalid)),
                                                   "has_dep", skip("block_guard")]

  internal_failure = [list: mk-node("failing", [list:], runner(internal-error("catastrophic error"))),
                            mk-node("has_dep", [list: "failing"], runner(emit(1)))]

  execute(internal_failure) is [SD.string-dict: "failing", res(internal-error("catastrophic error")),
                                                "has_dep", skip("failing")]

  blocking_dep = [list: mk-node("block_guard", [list:], runner(block(invalid))),
                        mk-node("has_dep1", [list: "block_guard"], runner(emit(1))),
                        mk-node("has_dep2", [list: "has_dep1"], runner(emit(2)))]
  execute(blocking_dep) is [SD.string-dict: "block_guard", res(block(invalid)),
                                            "has_dep1", skip("block_guard"),
                                            "has_dep2", skip("block_guard")]
  dep = [list: mk-node("pass_guard", [list:], runner(noop)),
               mk-node("has_dep1", [list: "pass_guard"], runner(emit(1))),
               mk-node("has_dep2", [list: "has_dep1"], runner(emit(2)))]
  execute(dep) is [SD.string-dict: "pass_guard", res(noop),
                                   "has_dep1", res(emit(1)),
                                   "has_dep2", res(emit(2))]
end

check "valid-dag":
  valid-dag = _valid-dag
  run = runner(emit(1))
  valid-dag(
    [list:
      mk-node("a", [list:], run),
      mk-node("b", [list: "a"], run),
      mk-node("c", [list: "a", "b"], run)])
    is true
  valid-dag(
    [list:
      mk-node("block_guard", [list:], runner(block("block reason"))),
      mk-node("has_dep1", [list: "block_guard"], runner(emit(1))),
      mk-node("has_dep2", [list: "has_dep1"], runner(emit(2)))])
    is true
  valid-dag(
    [list:
      mk-node("x", [list: "y"], run),
      mk-node("y", [list:], run)])
    is true
  valid-dag(
    [list:
      mk-node("x", [list: "y"], run),
      mk-node("z", [list:], run)])
    is false
  valid-dag(
    [list:
      mk-node("p", [list: "q"], run),
      mk-node("q", [list: "p"], run)])
  is false
end

check "topological-sort":
  topological-sort = _topological-sort
  run = runner(noop)
  ids = lam<B, R, E, I, C>(dag :: DAG<B, R, E, I, C>) -> List<String>:
    dag.map(_.id)
  end

  ids(topological-sort([list:])) is [list:]

  single = [list: mk-node("x", [list:], run)]
  ids(topological-sort(single)) is [list: "x"]

  chain = [list:
            mk-node("a", [list:], run),
            mk-node("b", [list: "a"], run),
            mk-node("c", [list: "b"], run)]
  ids(topological-sort(chain)) is [list: "a", "b", "c"]

  rev-chain = [list:
                mk-node("c", [list: "b"], run),
                mk-node("b", [list: "a"], run),
                mk-node("a", [list:], run)]
  ids(topological-sort(rev-chain)) is [list: "a", "b", "c"]

  branching = [list:
                mk-node("c", [list: "a"], run),
                mk-node("b", [list: "a"], run),
                mk-node("a", [list:], run)]
  ids(topological-sort(branching)) is [list: "a", "c", "b"]
end
