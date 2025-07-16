import lists as L
import sets as S
import string-dict as SD

include file("./utils.arr")

provide:
  data Node,
  data Outcome,

  type DAG,
  type Id,
  type Runner,
  type Outcome,

  execute,
  valid-dag as _valid-dag,
  topological-sort as _topological-sort
end

type Id = String

# TODO: still not convinced that info is the right approach
type Runner<BlockReason, RanResult, Error, Info> = 
  (-> {Outcome<BlockReason, RanResult, Error>; Info})

data Node<BlockReason, RanResult, Error, Context, Info>:
  # id: unique id of the node
  # deps: the dependencies of this node
  # run: the action that will be executed if dependencies are met
  # ctx: additional context associated with the Node
  | node(
      id :: Id,
      deps :: List<Id>,
      run :: Runner<BlockReason, RanResult, Error, Info>,
      ctx :: Context)
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
  # id: id of the node which produced this outcome
  method handle-skip(self, id :: Id) -> Option<Id>:
    cases (Outcome) self:
      | block(_) => some(id)
      | proceed => none
      | done(_) => none
      | artifact(_) => none
      | skipped(shadow id) => some(id)
      | internal-error(_) => some(id)
    end
  end
end

fun valid-dag<B, R, E, M, I>(
  dag :: List<Node<B, R, E, M, I>>
) -> Boolean block:
  ids = dag.map(_.id)
  no-dups = lam(): not(has-duplicates(ids)) end
  all-deps-exist = lam(): dag.all(lam(x): x.deps.all(ids.member(_)) end) end

  dict = list-to-stringdict(dag.map(lam(n): {n.id; n.deps} end))

  fun has-cycle-from(id :: Id, path-set :: S.Set<Id>):
    dict.get-value(id).any(lam(dep):
      path-set.member(dep) or
      has-cycle-from(dep, path-set.add(dep))
    end)
  end

  no-cycles = lam(): not(ids.any(lam(id): has-cycle-from(id, [S.list-set: id]) end)) end

  no-dups() and all-deps-exist() and no-cycles()
end

type DAG<BlockReason, RanResult, Error, Context, Info> =
  List<Node<BlockReason, RanResult, Error, Context, Info>>%(valid-dag)

fun topological-sort<B, R, E, C, I>(
  # dag :: DAG<B, R, E, C, I>) 
  dag :: List<Node<B, R, E, C, I>>
# ) -> DAG<B, R, E, C, I>:
) -> List<Node<B, R, E, C, I>>:
  doc: ```Return a new list whose order guarantees that every node appears only
          after all of its dependencies.```

  fun help(
    remaining :: List<Node<B, R, E, C, I>>,
    sorted :: List<Node<B, R, E, C, I>>,
    visited :: List<Id>
  ) -> List<Node<B, R, E, C, I>>:
    cases (List<Node<B, R, E, C, I>>) remaining:
      | empty => sorted
      | else =>
        ready = remaining.filter(lam(n): n.deps.all(visited.member(_)) end)
        rest = remaining.filter(lam(n): not(n.deps.all(visited.member(_))) end)
        help(rest, sorted + ready, visited + ready.map(_.id))
    end
  end

  help(dag, [list:], [list:])
end

fun should-skip<B, R, E, I>(
  results :: SD.StringDict<{Outcome<B, R, E>; I}>, 
  deps :: List<Id>
) -> Option<Id>:
  cases (List) deps:
    | empty => none
    | link(id, rst) =>
      cases (Option) results.get-value(id).{0}.handle-skip(id):
        | none => should-skip(results, rst)
        | some(responsible-id) => some(responsible-id)
      end
  end
end

fun execute<B, R, E, C, I>(
  # dag :: DAG<B, R, E, C, I>,
  dag :: List<Node<B, R, E, C, I>>, 
  skip :: (String -> {Outcome<B, R, E>; I})
) -> SD.StringDict<{Outcome<B, R, E>; I}>:
  doc: "executes the dag, propogating outcomes"

  fun help(
    shadow dag :: List<Node<B, R, E, C, I>>, 
    acc :: SD.StringDict<{Outcome<B, R, E>; I}>
  ) -> SD.StringDict<{Outcome<B, R, E>; I}>:
    cases (List<Node<B, R, E, C, I>>) dag:
      | empty => acc
      | link(shadow node, rst) =>
        help(rst,
          cases (Option) should-skip(acc, node.deps):
            | none => acc.set(node.id, node.run())
            | some(blocking-id) => acc.set(node.id, skip(blocking-id))
          end)
    end
  end

  sorted-dag = topological-sort(dag)
  help(sorted-dag, [SD.string-dict:])
end

