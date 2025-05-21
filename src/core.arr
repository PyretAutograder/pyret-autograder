import lists as L
import sets as S

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
  # reason: the reason the `block`er provided
  | skipped(id :: Id, reason :: BlockReason) 

  | internal-error(err :: Error)
end

fun valid-dag<BlockReason, RanResult, Error>(
  dag :: List<Node<BlockReason, RanResult, Error>>
) -> Boolean:
  block:
    ids = dag.map(_.id)
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
