provide:
  data Node,
  data Outcome,

  type Runner,
  type Id,
end

type Id = String

type Runner<BlockReason, RanResult, Error> = 
  (-> Outcome<BlockReason, RanResult, Error>)

type DAG = List<Node>

data Node:
  # id: unique id of the node
  # deps: the dependencies of this node
  # run: the 
  | node(
      id :: Id,
      deps :: List<Id>,
      run :: Runner)
end

data Outcome<BlockReason, RanResult, Error>:
  # reason: the reason for the block
  | block(reason :: BlockReason)
  | cont

  | ran(res :: RanResult)
  # path: the path of the artifacts 
  | artifact(path :: String)

  # id: the id of the node which `block`ed this node
  # reason: the reason the `block`er provided
  | skipped(id :: Id, reason :: BlockReason) 

  | internal-error(err :: Error)
end

fun topological-sort(dag :: DAG) -> DAG:
  doc: ""
  ...
end
