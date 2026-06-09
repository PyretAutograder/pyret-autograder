fun vertices(graph :: Graph) -> Set<String>:
  list-to-list-set(graph.map(_.a) + graph.map(_.b))
end

###############################
## Union-Find Implementation ##
###############################


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

  # CHAFF DIFFERENCE
  # alg-cmp(empty) and
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
