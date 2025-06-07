include file("../src/core.arr")
include file("../src/utils.arr")

import lists as L
import sets as S
import string-dict as SD

data ExBlockReason:
  | invalid
end

check "execute":
  execute(empty) is [SD.string-dict:]

  single = [list: node("1", [list:], lam(): done(1) end, true)]
  execute(single) is [SD.string-dict: "1", done(1)]

  simple_dep = [list: node("pass_guard", [list:], lam(): proceed end, false),
                      node("has_dep", [list: "pass_guard"], lam(): done(1) end, true)]
  execute(simple_dep) is [SD.string-dict: "pass_guard", proceed, "has_dep", done(1)]

  blocking_simple_dep = [list: node("block_guard", [list:], lam(): block(invalid) end, false),
                               node("has_dep", [list: "block_guard"], lam(): done(1) end, true)]
  execute(blocking_simple_dep) is [SD.string-dict: "block_guard", block(invalid), "has_dep", skipped("block_guard")]

  internal_failure = [list: node("failing", [list:], lam(): internal-error("catastrofic error") end, false),
                            node("has_dep", [list: "failing"], lam(): done(1) end, true)]

  execute(internal_failure) is [SD.string-dict: "failing", internal-error("catastrofic error"), "has_dep", skipped("failing")]

  blocking_dep = [list: node("block_guard", [list:], lam(): block(invalid) end, false),
                        node("has_dep1", [list: "block_guard"], lam(): done(1) end, true),
                        node("has_dep2", [list: "has_dep1"], lam(): done(2) end, true)]
  execute(blocking_dep) is [SD.string-dict: "block_guard", block(invalid),
                                            "has_dep1", skipped("block_guard"),
                                            "has_dep2", skipped("block_guard")]
  dep = [list: node("pass_guard", [list:], lam(): proceed end, false),
               node("has_dep1", [list: "pass_guard"], lam(): done(1) end, true),
               node("has_dep2", [list: "has_dep1"], lam(): done(2) end, true)]
  execute(dep) is [SD.string-dict: "pass_guard", proceed,
                                   "has_dep1", done(1),
                                   "has_dep2", done(2)]
end

check "valid-dag":
  valid-dag = _valid-dag
  run = lam(): done(1) end
  valid-dag(
    [list:
      node("a", [list:], run, none),
      node("b", [list: "a"], run, none),
      node("c", [list: "a", "b"], run, none)])
    is true
  valid-dag(
    [list:
      node("block_guard", [list:], lam(): block("block reason") end, none),
      node("has_dep1", [list: "block_guard"], lam(): done(1) end, none),
      node("has_dep2", [list: "has_dep1"], lam(): done(2) end, none)])
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
  run = lam(): proceed end
  ids = lam(dag): dag.map(_.id) end

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
