import lists as L
import sets as S
import string-dict as SD

include file("utils.arr")

provide:
  data Node,
  data Outcome,

  type DAG,
  type Id,
  type Runner,
  type Outcome,
end

type Id = String

type Runner<BlockReason, RanResult, Error> = 
  (-> Outcome<BlockReason, RanResult, Error>)

data Node<BlockReason, RanResult, Error>:
  # id: unique id of the node
  # deps: the dependencies of this node
  # run: the action that will be executed if dependencies are met
  | node(
      id :: Id,
      deps :: List<Id>,
      run :: Runner<BlockReason, RanResult, Error>)
end

data Outcome<BlockReason, RanResult, Error>:
  # reason: the reason for the block
  | block(reason :: BlockReason)
  # node has no effect 
  | proceed
 
  | done(res :: RanResult)
  # path: the path of the artifacts 
  | artifact(path :: String)

  # id: the id of the node which `block`ed this node
  | skipped(id :: Id) 

  | internal-error(err :: Error)
sharing:
  method should-skip(self) -> Boolean:
    cases (Outcome) self:
    | block(_) => true
    | proceed => false
    | done(_) => false
    | artifact(_) => false
    | skipped(_) => true
    | internal-error(_) => true
    end
  end
end

fun valid-dag<BlockReason, RanResult, Error>(
  dag :: List<Node<BlockReason, RanResult, Error>>
) -> Boolean:
  block:
    ids = dag.map(_.id)

    # TODO: make sure that there are no cycles, etc

    not(has-duplicates(ids)) and
    dag.all(lam(x): x.deps.all(ids.member(_)) end)
  end
where:
  run = lam(): done(1) end
  valid-dag(
    [list:
      node("a", [list:], run),
      node("b", [list:"a"], run),
      node("c", [list:"a", "b"], run)])
    is true
end

type DAG<BlockReason, RanResult, Error> = 
  List<Node<BlockReason, RanResult, Error>>%(valid-dag)

fun topological-sort<BlockReason, RanResult, Error>(
  dag :: DAG<BlockReason, RanResult, Error>
) -> DAG<BlockReason, RanResult, Error>:
  doc: ""
  ...
end


data ExBlockReason:
| invalid
end


type StrDictOut = SD.StringDict<Outcome<ExBlockReason, Number, String>>
fun should-skip(results :: StrDictOut, deps :: List<Id>) -> Option<Id>:
  cases (List) deps:
  | empty => none
  | link(id, rst) =>
    cases (Option) results.get(id):
    | none => raise("oops")
    | some(outcome) => 
      if outcome.should-skip():
        some(id)
      else:
        should-skip(results, rst)
      end
    end
  end
end
fun execute(dag :: DAG<ExBlockReason, Number, String>) -> SD.StringDict<Outcome<ExBlockReason, Number, String>>:
  doc: "assume topo sort"
  
  fun help(shadow dag, acc):
    cases (List) dag:
    | empty => acc
    | link(shadow node, rst) => 
      help(rst, 
        cases (Option) should-skip(acc, node.deps):
        | none => acc.set(node.id, node.run())
        | some(blocking-id) => acc.set(node.id, skipped(blocking-id))
        end)
    end
  end
  
  help(dag, [SD.string-dict:])
where: 
  execute(empty) is [SD.string-dict:]

  single = [list: node("1", [list:], lam(): done(1) end)]
  execute(single) is [SD.string-dict: "1", done(1)]

  simple_dep = [list: node("pass_guard", [list:], lam(): proceed end),
                      node("has_dep", [list: "pass_guard"], lam(): done(1) end)]
  execute(simple_dep) is [SD.string-dict: "pass_guard", proceed, "has_dep", done(1)]
  
  blocking_simple_dep = [list: node("block_guard", [list:], lam(): block(invalid) end),
                               node("has_dep", [list: "block_guard"], lam(): done(1) end)]
  execute(blocking_simple_dep) is [SD.string-dict: "block_guard", block(invalid), "has_dep", skipped("block_guard")]

  internal_failure = [list: node("failing", [list:], lam(): internal-error("catastrofic error") end),
                            node("has_dep", [list: "failing"], lam(): done(1) end)]

  execute(internal_failure) is [SD.string-dict: "failing", internal-error("catastrofic error"), "has_dep", skipped("failing")]

  blocking_dep = [list: node("block_guard", [list:], lam(): block(invalid) end),
                        node("has_dep1", [list: "block_guard"], lam(): done(1) end),
                        node("has_dep2", [list: "has_dep1"], lam(): done(2) end)]
  execute(blocking_dep) is [SD.string-dict: "block_guard", block(invalid), 
                                            "has_dep1", skipped("block_guard"),
                                            "has_dep2", skipped("block_guard")]
  dep = [list: node("pass_guard", [list:], lam(): proceed end),
               node("has_dep1", [list: "pass_guard"], lam(): done(1) end),
               node("has_dep2", [list: "has_dep1"], lam(): done(2) end)]
  execute(dep) is [SD.string-dict: "pass_guard", proceed, 
                                   "has_dep1", done(1),
                                   "has_dep2", done(2)]
end 

