provide: mst-prim, mst-kruskal, generate-input, mst-cmp, sort-o-cle end
# END HEADER

include file("submission/assignment-support.arr")

# ---- reference implementation (own union-find: Element) ----

include string-dict

fun vertices(graph :: Graph) -> Set<String>:
  list-to-list-set(graph.map(_.a) + graph.map(_.b))
end

###############################
## Union-Find Implementation ##
###############################

data Element<T>:
  | elt(val :: T, ref parent :: Option<Element<T>>)
end

fun is-in-same-set<T>(e1 :: Element<T>, e2 :: Element<T>) -> Boolean:
  s1 = fynd(e1)
  s2 = fynd(e2)
  identical(s1, s2)
end

fun update-set-with<T>(child :: Element<T>, parent :: Element<T>) -> Element<T>:
  child!{parent: some(parent)}
end

fun union<T>(e1 :: Element<T>, e2 :: Element<T>) -> Element<T>:
  s1 = fynd(e1)
  s2 = fynd(e2)
  if identical(s1, s2):
    s1
  else:
    update-set-with(s1, s2)
  end
end

fun fynd<T>(e :: Element<T>) -> Element<T>:
  cases (Option) e!parent block:
    | none => e
    | some(p) =>
      new-parent = fynd(p)
      e!{parent: some(new-parent)}
      new-parent
  end
end


fun make-sets(graph :: Graph) -> StringDict<Element<String>>:
  vertices(graph).fold({(ufs, v): ufs.set(v, elt(v, none))}, [string-dict: ])
end

#########################
## MST Implementations ##
#########################

fun mst-kruskal(graph :: Graph) -> List<Edge>:
  # Make union-find sets
  ufs = make-sets(graph)
  
  # Sort edges by weight
  sorted-edges = graph.sort-by({(a, b): a.weight < b.weight}, {(a, b): a.weight == b.weight})
  
  for fold(result :: Graph from empty, e :: Edge from sorted-edges):
    start = ufs.get-value(e.a)
    dest = ufs.get-value(e.b)

    if is-in-same-set(start, dest) block:
      # Don't add edge, as doing so would create a cycle
      result
    else:
      # Add the edge and union the sets of its vertices
      union(start, dest)
      link(e, result)
    end
  end
end

fun mst-prim(graph :: Graph) -> List<Edge>:
  mst-kruskal(graph)
end

################
## Generation ##
################

fun generate-edge(src :: String, dest :: String) -> Edge:
  doc: "Generates an edge between two strings representing nodes"
  dist = (num-random(200) - 100) / (num-random(10) + 1)
  # Added above for slightly nicer random distribution, can be tinkered with
  if src < dest:
    edge(src, dest, dist)
  else:
    edge(dest, src, dist)
  end
end

fun generate-st(max :: Number, l :: Number, nodes :: List<String>, edges :: List<Edge>)
  -> {List<Edge>; List<String>}:
  doc: ```Generates a spanning tree with max number of nodes. Returns
       a tuple of the edges and nodes```
  if l == 0:
    {edges; nodes}
  else:
    size = max - l - 1
    # Choose a random node already on the tree to connect to
    src = nodes.get(num-random(size))
    # Guaranteed unique val per element
    dest = "n_" + num-to-string(l)
    new-edge = generate-edge(src, dest)
    generate-st(max, l - 1, link(dest, nodes), link(new-edge, edges))
  end
end

fun generate-neighbors(src :: String, others :: List<String>, edges :: List<Edge>, prob :: Number)
  -> List<Edge>:
  doc: "Generates edges connecting src to the nodes in others, each with probability <prob>%"
  for fold(shadow edges from edges, neighbor from others):
    if num-random(100) < prob:
      link(generate-edge(neighbor, src), edges)
    else:
      edges
    end
  end
end

fun add-edges(nodes :: List<String>, edges :: List<Edge>, prob :: Number) -> List<Edge>:
  doc: ```For each node, generates neighbours with the rest of the nodes```
  cases (List) nodes:
    | empty => edges
    | link(f, r) =>
      new-edges = generate-neighbors(f, r, edges, prob)
      add-edges(r, new-edges, prob)
  end
end

fun generate-input(n :: Number) -> Graph:
  doc: ```Given a number n, generates a dense graph with potential multiple edges and n nodes```
  if n < 2:
    empty
  else:
    src = "n_" + num-to-string(n)
    dest = "n_" + num-to-string(n - 1)
    new-edge = generate-edge(src, dest)
    
    # First, generate the spanning tree
    {edges; nodes} = generate-st(n, n - 2, [list: src, dest], [list: new-edge])
    
    # Then, fill up the tree with edges, each edge with probability <prob>%
    # Biased toward sparser graphs
    prob = (num-random(10) + 1) * (num-random(10) + 1)
    add-edges(nodes, edges, prob)
  end
end

#####################
## Tree Comparison ##
#####################

fun mst-cmp(g :: Graph, mst1 :: Graph, mst2 :: Graph) -> Boolean:
  doc: "Checks if two mst algorithms are valid on a graph"
  cases (List) g:
    | empty => is-empty(mst1) and is-empty(mst2)
    | link(_, _) =>
      (weigh-tree(mst1) == weigh-tree(mst2)) and
      spanning-tree(mst1, g) and spanning-tree(mst2, g) and
      same-edges(g, mst1, mst2)
  end
end

fun weigh-tree(mst :: Graph) -> Number:
  doc: "Returns the cumulative weight of all edges in a graph"
  mst.foldl({(e, acc): e.weight + acc}, 0)
end

fun connected(tree :: Graph) -> Boolean block:
  doc: ```For every edge in the tree, checks if src and dest and in the same
       set as an arbitrary node (tree.first.a) after connecting src and dest
       for every edge. Basically, this will return false if the tree is a forest```
  is-empty(tree) or block:
    ufs = make-sets(tree)
    # Union the sets of the vertices of each vertex
    tree.map({(e): union(ufs.get-value(e.a), ufs.get-value(e.b))})

    node = tree.get(0).a
    s = ufs.get-value(node)
    tree.all({(e): is-in-same-set(s, ufs.get-value(e.a)) and is-in-same-set(s, ufs.get-value(e.b))})
  end
end

fun spanning-tree(mst :: Graph, g :: Graph) -> Boolean:
  doc: ```Checks if mst is a connected graph. (Connected)
       Checks if every node in the graph is in the mst. (Spanning)
       Checks if mst contains one fewer edge than node. (Tree)```
  mst-nodes = vertices(mst)
  # Three conditions guarantee a connected spanning tree
  connected(mst) and
  (vertices(g) == mst-nodes) and
  (mst.length() == (mst-nodes.size() - 1))
end

fun same-edges(graph :: Graph, mst1 :: Graph, mst2 :: Graph) -> Boolean :
  lists.all({(e): graph.member(e)}, mst1) and
  lists.all({(e): graph.member(e)}, mst2)
end


################
## Sort-o-cle ##
################

fun count<A>(target :: A, a :: List<A>) -> Number:
  el-checker = lam(el, cnt :: Number): 
    if el == target:
      cnt + 1
    else:
      cnt
    end
  end
  a.foldl(el-checker, 0)
end

fun lst-same-els<A>(a :: List<A>, b :: List<A>) -> Boolean:
  same-count = lam(el): (count(el, a) == count(el, b)) end
  (a.length() == b.length()) and lists.all(same-count, a)
end

cities :: Graph = [list:
    edge("Chicago", "Newark", 5),
    edge("Newark", "Denver", 2),
    edge("Newark", "Chicago", 1), 
    edge("Newark", "San Francisco", 3), 
    edge("Houston", "San Francisco", 8), 
    edge("Denver", "Newark", 9), 
    edge("Chicago", "San Francisco", 6), 
    edge("San Francisco", "Houston", 13), 
    edge("Houston", "Newark", 7), 
    edge("Denver", "San Francisco", 10), 
    edge("San Francisco", "Denver", 12), edge("San Francisco", "Newark", 11),
    edge("Newark", "Houston", 4)]

wiki = [list:
  edge("A", "B", 1),
  edge("B", "C", 6),
  edge("C", "F", 2),
  edge("E", "F", 4),
  edge("E", "D", 1),
  edge("A", "D", 3),
  edge("E", "B", 1),
  edge("D", "B", 5),
  edge("C", "E", 5)]

pyramid = [list:
  edge("alpha", "beta", 1),
  edge("alpha", "gamma", 1),
  edge("alpha", "delta", 1),
  edge("beta", "gamma", 1),
  edge("beta", "delta", 1),
  edge("gamma", "delta", 1)]

fun sort-o-cle(alg1 :: (Graph -> Graph), alg2 :: (Graph -> Graph)) -> Boolean:
  doc: "Given two MST algorithms, returns a boolean for their validity"
  alg-cmp = {(in): mst-cmp(in, alg1(in), alg2(in))}
  
  alg-cmp(empty) and
  alg-cmp([list: edge("src", "dest", 3.4)]) and
  # Hand-checked normal cases
  alg-cmp(cities) and
  alg-cmp(wiki) and
  # Edge case: all edges same length
  alg-cmp(pyramid) and
  # Random tests
  alg-cmp(generate-input(10)) and
  alg-cmp(generate-input(25)) and
  alg-cmp(generate-input(40))
end

# ---- test fixtures ----

g3 = [list: edge("A", "B", 1), edge("B", "C", 2), edge("A", "C", 3)]
valid3 = [list: edge("A", "B", 1), edge("B", "C", 2)]
# spanning tree of g3 by vertices/weight, but uses A-C(1) which is NOT in g3:
foreign3 = [list: edge("A", "B", 1), edge("A", "C", 2)]

g4 = [list: edge("A", "B", 1), edge("C", "D", 1), edge("B", "C", 1), edge("A", "D", 1)]
valid4 = [list: edge("A", "B", 1), edge("B", "C", 1), edge("C", "D", 1)]
# spans {A,B,C,D} with n-1 edges, but disconnected (A-B | C-D):
disconnected4 = [list: edge("A", "B", 1), edge("A", "B", 1), edge("C", "D", 1)]
# two DIFFERENT valid MSTs of g4:
mstA4 = [list: edge("A", "B", 1), edge("B", "C", 1), edge("C", "D", 1)]
mstB4 = [list: edge("B", "C", 1), edge("C", "D", 1), edge("A", "D", 1)]

# ---- tests, routed per function under test ----

check "mst-kruskal":
  mst-kruskal(empty) is empty
  # works on negative weights (catches "errors on negative weight")
  mst-kruskal([list: edge("A", "B", -5)]) is [list: edge("A", "B", -5)]
  is-spanning-tree(mst-kruskal(g3), g3) is true
  get-total-weight(mst-kruskal(g3)) is 3
end

check "mst-prim":
  mst-prim(empty) is empty
  mst-prim([list: edge("A", "B", -5)]) is [list: edge("A", "B", -5)]
  is-spanning-tree(mst-prim(g3), g3) is true
  get-total-weight(mst-prim(g3)) is 3
end

check "generate-input":
  # correct count of vertices (catches "wrong number of nodes")
  extract-vertices(generate-input(10)).length() is 10
  # no self-loops (catches "produces unconnected", which inserts self-loops)
  generate-input(10).all(lam(e): not(e.a == e.b) end) is true
  is-connected-graph(generate-input(10)) is true
end

check "mst-cmp":
  # baseline: a valid MST compared with itself
  mst-cmp(g3, valid3, valid3) is true
  # mst uses an edge not present in the graph (catches doesnt-check-edges-present)
  mst-cmp(g3, foreign3, valid3) is false
  # mst spans all vertices with n-1 edges but is disconnected
  # (catches doesnt-check-if-connected)
  mst-cmp(g4, disconnected4, valid4) is false
  # mst is connected and spanning but not a tree (a full cycle)
  # (catches doesnt-check-if-tree)
  mst-cmp(g4, g4, g4) is false
  # two DIFFERENT but equally-valid MSTs (catches mst-cmp using set equality)
  mst-cmp(g4, mstA4, mstB4) is true
end

check "sort-o-cle":
  # two correct algorithms agree
  sort-o-cle(mst-kruskal, mst-prim) is true
  # a correct algorithm vs one that always returns empty
  # (catches sort-o-cle that always passes)
  sort-o-cle(mst-kruskal, lam(g :: Graph): empty end) is false
  # two valid-but-NON-minimal spanning-tree algorithms agree
  # (catches sort-o-cle that also requires minimality vs kruskal)
  max-span = lam(g :: Graph):
    neg = g.map(lam(e :: Edge): edge(e.a, e.b, 0 - e.weight) end)
    mst-kruskal(neg).map(lam(e :: Edge): edge(e.a, e.b, 0 - e.weight) end)
  end
  sort-o-cle(max-span, max-span) is true
  # an algorithm wrong ONLY on the empty graph
  # (catches sort-o-cle that fails to check the empty graph)
  bad-on-empty = lam(g :: Graph):
    if is-empty(g): [list: edge("x", "y", 0)] else: mst-kruskal(g) end
  end
  sort-o-cle(bad-on-empty, bad-on-empty) is false
end
