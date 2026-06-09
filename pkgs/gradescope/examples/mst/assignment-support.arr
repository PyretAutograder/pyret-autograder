provide:
  data Edge,
  type Graph,
  check-lists-have-same-edges,
  extract-vertices,
  is-connected-graph,
  is-spanning-tree,
  get-total-weight,
end

import equality as Eq

# ---- given definitions (mst-definitions.arr) ----

data Edge:
  | edge(a :: String, b :: String, weight :: Number)
    with:
    method _equals(self :: Edge, other :: Edge, equal-rec :: (Any, Any -> Eq.EqualityResult))
      -> Eq.EqualityResult:
      eq = {(a, b): Eq.is-Equal(equal-rec(a, b))}
      {a1; b1; w1} = cases (Edge) self:
        | edge(a, b, weight) => {a; b; weight}
      end
      {a2; b2; w2} = cases (Edge) other:
        | edge(a, b, weight) => {a; b; weight}
      end
      ask:
        | not(eq(w1, w2)) then: Eq.NotEqual("different weights", w1, w2)
        | (eq(a1, a2) and eq(b1, b2)) or (eq(a1, b2) and eq(b1, a2)) then: Eq.Equal
        | otherwise: Eq.NotEqual("different vertices", self, other)
      end
    end
end

type Graph = List<Edge>

# ---- given test-suite support (mst-test-suite-support.arr) ----
# NOTE: this union-find (TAElement/fynd/union/same-set) is kept PRIVATE (not
# provided) so it does not collide with the wheat/chaff's own union-find
# (Element/fynd/union) that the merge splices into the student program.

data TAElement<T>:
  | ta-elt(val :: T, ref parent :: Option<TAElement<T>>)
end

fun fynd<T>(v :: TAElement<T>) -> TAElement<T>:
  cases (Option) v!parent:
    | none => v
    | some(p) => fynd(p)
  end
end

fun union<T>(e1 :: TAElement<T>, e2 :: TAElement<T>) -> TAElement<T>:
  s1 = fynd(e1)
  s2 = fynd(e2)
  if identical(s1, s2): s1
  else: s1!{parent: some(s2)}
  end
end

fun same-set<T>(e1 :: TAElement<T>, e2 :: TAElement<T>) -> Boolean:
  identical(fynd(e1), fynd(e2))
end

fun list-to-set-elements<T>(initial-list :: List<T>) -> List<TAElement<T>>:
  lists.map(lam(value :: T) -> TAElement<T>: ta-elt(value, none) end, initial-list)
end

fun find-element<T>(value :: T, element-list :: List<TAElement<T>>) -> TAElement<T>:
  lists.find(lam(element :: TAElement<T>): element.val == value end, element-list).value
end

fun are-all-elements-in-same-set<T>(elements :: List<TAElement<T>>) -> Boolean:
  cases (List) elements:
    | empty => true
    | link(arbitrary-element, r) =>
      lists.all(lam(element :: TAElement<T>): same-set(element, arbitrary-element) end, r)
  end
end

fun link-if-unique<T>(element :: T, lst :: List<T>) -> List<T>:
  if lst.member(element): lst else: link(element, lst) end
end

fun extract-vertices(graph :: Graph) -> List<String>:
  lists.fold(
    lam(vertices :: List<String>, e :: Edge) -> List<String>:
      link-if-unique(e.b, link-if-unique(e.a, vertices))
    end,
    empty, graph)
end

fun check-lists-have-same-edges(edges-a :: List<Edge>, edges-b :: List<Edge>) -> Boolean:
  fun same-edge(edge-1 :: Edge, edge-2 :: Edge) -> Boolean:
    (edge-1.weight == edge-2.weight) and
    (((edge-1.a == edge-2.a) and (edge-1.b == edge-2.b)) or
      ((edge-1.a == edge-2.b) and (edge-1.b == edge-2.a)))
  end
  fun find-and-remove(e :: Edge, lst :: List<Edge>) -> Option<List<Edge>>:
    cases (List) lst:
      | empty => none
      | link(f, r) =>
        if same-edge(e, f): some(r)
        else:
          cases (Option) find-and-remove(e, r):
            | none => none
            | some(l) => some(link(f, l))
          end
        end
    end
  end
  cases (List) edges-a:
    | empty => is-empty(edges-b)
    | link(f, r) =>
      cases (Option) find-and-remove(f, edges-b):
        | none => false
        | some(updated-b) => check-lists-have-same-edges(r, updated-b)
      end
  end
end

fun is-connected-graph(graph :: Graph) -> Boolean:
  fun helper(vertex-sets :: List<TAElement<String>>, remaining-edges :: List<Edge>) -> Boolean:
    cases (List) remaining-edges block:
      | empty => are-all-elements-in-same-set(vertex-sets)
      | link(f, r) =>
        element-a = find-element(f.a, vertex-sets)
        element-b = find-element(f.b, vertex-sets)
        union(element-a, element-b)
        helper(vertex-sets, r)
    end
  end
  vertex-names = extract-vertices(graph)
  vertex-sets = list-to-set-elements(vertex-names)
  helper(vertex-sets, graph)
end

fun is-tree(edges :: List<Edge>) -> Boolean:
  fun helper(vertex-sets :: List<TAElement<String>>, remaining-edges :: List<Edge>) -> Boolean:
    cases (List) remaining-edges block:
      | empty => are-all-elements-in-same-set(vertex-sets)
      | link(f, r) =>
        element-a = find-element(f.a, vertex-sets)
        element-b = find-element(f.b, vertex-sets)
        if same-set(element-a, element-b) block:
          false
        else:
          union(element-a, element-b)
          helper(vertex-sets, r)
        end
    end
  end
  vertex-names = extract-vertices(edges)
  vertex-sets = list-to-set-elements(vertex-names)
  helper(vertex-sets, edges)
end

fun is-tree-from-graph(tree :: List<Edge>, graph :: Graph) -> Boolean:
  fun edge-reorderer(e :: Edge) -> Edge:
    if e.a < e.b: edge(e.a, e.b, e.weight) else: edge(e.b, e.a, e.weight) end
  end
  tree-reordered = tree.map(edge-reorderer)
  graph-reordered = graph.map(edge-reorderer)
  tree-edges = sets.list-to-set(tree-reordered)
  graph-edges = sets.list-to-set(graph-reordered)
  tree-edges.difference(graph-edges).size() == 0
end

fun is-spanning(tree :: List<Edge>, graph :: Graph) -> Boolean:
  tree-vertices = sets.list-to-list-set(extract-vertices(tree))
  graph-vertices = sets.list-to-list-set(extract-vertices(graph))
  tree-vertices == graph-vertices
end

fun is-spanning-tree(edges :: List<Edge>, graph :: Graph) -> Boolean:
  is-tree(edges) and is-tree-from-graph(edges, graph) and is-spanning(edges, graph)
end

fun get-total-weight(tree :: List<Edge>) -> Number:
  lists.fold(lam(acc :: Number, e :: Edge) -> Number: acc + e.weight end, 0, tree)
end
