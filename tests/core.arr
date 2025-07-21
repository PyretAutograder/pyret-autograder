include file("../src/core.arr")
include file("../src/utils.arr")

import lists as L
import sets as S
import string-dict as SD

data ExBlockReason:
  | invalid
end

fun runner(val):
  lam():
    {val; none}
  end
end

fun res(outcome):
  executed(outcome, none)
end

fun skip(id):
  skipped(id)
end


check "execute":
  execute(empty) is [SD.string-dict:]

  single = [list: node("1", [list:], runner(emit(1)), true)]
  execute(single) is [SD.string-dict: "1", res(emit(1))]

  simple_dep = [list: node("pass_guard", [list:], runner(noop), false),
                      node("has_dep", [list: "pass_guard"], runner(emit(1)), true)]
  execute(simple_dep) is [SD.string-dict: "pass_guard", res(noop), "has_dep", res(emit(1))]

  blocking_simple_dep = [list: node("block_guard", [list:], runner(block(invalid)), false),
                               node("has_dep", [list: "block_guard"], runner(emit(1)), true)]
  execute(blocking_simple_dep) is [SD.string-dict: "block_guard", res(block(invalid)), 
                                                   "has_dep", skip("block_guard")]

  internal_failure = [list: node("failing", [list:], runner(internal-error("catastrophic error")), false),
                            node("has_dep", [list: "failing"], runner(emit(1)), true)]

  execute(internal_failure) is [SD.string-dict: "failing", res(internal-error("catastrophic error")), 
                                                "has_dep", skip("failing")]

  blocking_dep = [list: node("block_guard", [list:], runner(block(invalid)), false),
                        node("has_dep1", [list: "block_guard"], runner(emit(1)), true),
                        node("has_dep2", [list: "has_dep1"], runner(emit(2)), true)]
  execute(blocking_dep) is [SD.string-dict: "block_guard", res(block(invalid)),
                                            "has_dep1", skip("block_guard"),
                                            "has_dep2", skip("block_guard")]
  dep = [list: node("pass_guard", [list:], runner(noop), false),
               node("has_dep1", [list: "pass_guard"], runner(emit(1)), true),
               node("has_dep2", [list: "has_dep1"], runner(emit(2)), true)]
  execute(dep) is [SD.string-dict: "pass_guard", res(noop),
                                   "has_dep1", res(emit(1)),
                                   "has_dep2", res(emit(2))]
end

check "valid-dag":
  valid-dag = _valid-dag
  run = runner(emit(1))
  valid-dag(
    [list:
      node("a", [list:], run, none),
      node("b", [list: "a"], run, none),
      node("c", [list: "a", "b"], run, none)])
    is true
  valid-dag(
    [list:
      node("block_guard", [list:], runner(block("block reason")), none),
      node("has_dep1", [list: "block_guard"], runner(emit(1)), none),
      node("has_dep2", [list: "has_dep1"], runner(emit(2)), none)])
    is true
  valid-dag(
    [list:
      node("x", [list: "y"], run, none),
      node("y", [list:], run, none)])
    is true
  valid-dag(
    [list:
      node("x", [list: "y"], run, none),
      node("z", [list:], run, none)])
    is false
  valid-dag(
    [list:
      node("p", [list: "q"], run, none),
      node("q", [list: "p"], run, none)])
  is false
end

check "topological-sort":
  topological-sort = _topological-sort
  run = runner(noop)
  ids = lam<B, R, E, I, C>(dag :: DAG<B, R, E, I, C>) -> List<String>: 
    dag.map(_.id) 
  end

  ids(topological-sort([list:])) is [list:]

  single = [list: node("x", [list:], run, true)]
  ids(topological-sort(single)) is [list: "x"]

  chain = [list:
            node("a", [list:], run, true),
            node("b", [list: "a"], run, true),
            node("c", [list: "b"], run, true)]
  ids(topological-sort(chain)) is [list: "a", "b", "c"]

  rev-chain = [list:
                node("c", [list: "b"], run, true),
                node("b", [list: "a"], run, true),
                node("a", [list:], run, true)]
  ids(topological-sort(rev-chain)) is [list: "a", "b", "c"]

  branching = [list:
                node("c", [list: "a"], run, true),
                node("b", [list: "a"], run, true),
                node("a", [list:], run, true)]
  ids(topological-sort(branching)) is [list: "a", "c", "b"]
end
