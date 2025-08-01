import lists as L
import sets as S
import string-dict as SD

include file("./utils.arr")

provide:
  data Node,
  data Outcome,
  data NodeResult,

  type Id,
  type DAG,
  type Runner,
  type RunnerOutput,

  execute,
  valid-dag as _valid-dag,
  topological-sort as _topological-sort
end

type Id = String

type RunnerOutput<BlockReason, RanResult, Error, Info> =
  {Outcome<BlockReason, RanResult, Error>; Info}

type Runner<BlockReason, RanResult, Error, Info> =
  (-> RunnerOutput<BlockReason, RanResult, Error, Info>)

data Node<BlockReason, RanResult, Error, Info, Context>:
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
  # blocks further execution
  # reason: the reason for the block
  | block(reason :: BlockReason)

  # node has no effect on execution
  | noop

  # yields a result
  # res: the result
  | emit(res :: RanResult)

  # an internal issue occured in a runner
  # err: the error which occured
  | internal-error(err :: Error)
end

data NodeResult<BlockReason, RanResult, Error, Info, Context>:
  # node was run
  # outcome: the result of the runner
  # info: additional information provided by the runner
  # ctx: additional context associated with the Node
  | executed(
      outcome :: Outcome<BlockReason, RanResult, Error>,
      info :: Info,
      ctx :: Context)

  # node wasn't run because of unmet dependency
  # id: the id of the node which stopped further execution
  # ctx: additional context associated with the Node
  | skipped(id :: Id, ctx :: Context)
sharing:
  method determine-blocking-node(self, id :: Id) -> Option<Id>:
    doc: ```
      Given the `id` of the node which produced this result,
      returns an Option which either:
      - contains the id which should be blamed for blocking downstream execution
      - contains nothing if execution should continue
    ```

    cases (NodeResult) self:
      | executed(outcome, _, _) =>
        cases (Outcome) outcome:
          | block(_) => some(id)
          | noop => none
          | emit(_) => none
          | internal-error(_) => some(id)
        end
      | skipped(orig-id, _) => some(orig-id)
    end
  end
end

fun valid-dag<B, R, E, I, C>(
  dag :: List<Node<B, R, E, I, C>>
) -> Boolean block:
  doc: ```
    Determines if a list of nodes form a valid directed acyclic graph (DAG)
    meaning that:
    - they don't form cycles
    - each node has a unique id
  ```
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

type DAG<BlockReason, RanResult, Error, Info, Context> =
  List<Node<BlockReason, RanResult, Error, Info, Context>>%(valid-dag)

fun topological-sort<B, R, E, I, C>(
  dag :: DAG<B, R, E, I, C>
) -> DAG<B, R, E, I, C>:
  doc: ```
    Sorts the directed acyclic graph such that the ordering guarantees that
    every node appears only after all of its dependencies.
  ```

  fun help(
    remaining :: List<Node<B, R, E, I, C>>,
    sorted :: List<Node<B, R, E, I, C>>,
    visited :: List<Id>
  ) -> List<Node<B, R, E, I, C>>:
    cases (List<Node<B, R, E, I, C>>) remaining:
      | empty => sorted
      | else =>
        ready = remaining.filter(lam(n): n.deps.all(visited.member(_)) end)
        rest = remaining.filter(lam(n): not(n.deps.all(visited.member(_))) end)
        help(rest, sorted + ready, visited + ready.map(_.id))
    end
  end

  help(dag, [list:], [list:])
end

fun check-dependencies<B, R, E, I, C>(
  results :: SD.StringDict<NodeResult<B, R, E, I, C>>,
  deps :: List<Id>
) -> Option<Id>:
  doc: ```
    Given the dependencies, `deps`, of a topologically sorted DAG, and all the
    result of all previously executed nodes, `results`, check to see that any
    of the dependencies should block the execution of the given node.
    Returns the ID of the node responsible for or none if all dependencies are
    satisfied.
  ```
  cases (List) deps:
    | empty => none
    | link(id, rst) =>
      cases (Option) results.get-value(id).determine-blocking-node(id):
        | none => check-dependencies(results, rst)
        | some(responsible-id) => some(responsible-id)
      end
  end
end

fun execute<B, R, E, I, C>(
  dag :: DAG<B, R, E, I, C>
) -> SD.StringDict<NodeResult<B, R, E, I, C>>:
  doc: "executes the dag, propagating outcomes"

  fun help(
    shadow dag :: List<Node<B, R, E, I, C>>,
    acc :: SD.StringDict<NodeResult<B, R, E, I, C>>
  ) -> SD.StringDict<NodeResult<B, R, E, I, C>>:
    cases (List<Node<B, R, E, I, C>>) dag:
      | empty => acc
      | link(shadow node, rst) =>
        cases (Option) check-dependencies(acc, node.deps):
          | none =>
            {outcome; info} = node.run()
            acc.set(node.id, executed(outcome, info, node.ctx))
          | some(blocking-id) =>
            acc.set(node.id, skipped(blocking-id, node.ctx))
        end
        ^ help(rst, _)
    end
  end

  sorted-dag = topological-sort(dag)
  help(sorted-dag, [SD.string-dict:])
end

