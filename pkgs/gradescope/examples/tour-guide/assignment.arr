provide: dijkstra, campus-tour end
# END HEADER

include file("submission/assignment-support.arr")
import string-dict as SD

# ---- test fixtures (graphs and places) ----
tg-loc-A = place("tg-loc-A", point(0, 0), [set: "tg-loc-B"])
tg-loc-B = place("tg-loc-B", point(0, 1), [set: "tg-loc-A", "tg-loc-C"])
tg-loc-C = place("tg-loc-C", point(0, 2), [set: "tg-loc-B", "tg-loc-D"])
tg-loc-D = place("tg-loc-D", point(0, 3), [set: "tg-loc-C", "tg-loc-E"])
tg-loc-E = place("tg-loc-E", point(0, 4), [set: "tg-loc-D"])



#Graph where all distances are equal
# G - H - I 
# |   |   |
# J - K - L
# |   |   |
# M - N - O
# graph:
tg-loc-G = place("tg-loc-G", point(0, 0), [set: "tg-loc-H", "tg-loc-J"])
tg-loc-H = place("tg-loc-H", point(0, 1), 
  [set: "tg-loc-G", "tg-loc-I", "tg-loc-K"])
tg-loc-I = place("tg-loc-I", point(0, 2), [set: "tg-loc-H", "tg-loc-L"])
tg-loc-J = place("tg-loc-J", point(-1, 0), [set: "tg-loc-G", "tg-loc-K", "tg-loc-M"])
tg-loc-K = place("tg-loc-K", point(-1, 1), 
  [set: "tg-loc-H", "tg-loc-J", "tg-loc-L", "tg-loc-N"])
tg-loc-L = place("tg-loc-L", point(-1, 2), [set: "tg-loc-K", "tg-loc-I", "tg-loc-O"])
tg-loc-M = place("tg-loc-M", point(-2, 0), [set: "tg-loc-J", "tg-loc-N"])
tg-loc-N = place("tg-loc-N", point(-2, 1), [set: "tg-loc-M", "tg-loc-K", "tg-loc-O"])
tg-loc-O = place("tg-loc-O", point(-2, 2), [set: "tg-loc-N", "tg-loc-L"])

equal-dist-graph = [set: tg-loc-G,tg-loc-H,tg-loc-J,tg-loc-I,
  tg-loc-K,tg-loc-L,tg-loc-M,tg-loc-N,tg-loc-O]

# ---- reference implementation (helpers + dijkstra + campus-tour) ----
#| wheat (mheller6, Sep 3, 2020): 
    Breaks dijkstra ties lexicographically.
    Breaks campus-tour ties reverse-lexicographically.
    Ignores tour stops that aren't in graph.
    Ignores non-unique tour names.
|#

data HeapPath:
  | heap-path(name :: Name, distance-from-start :: Number, path :: Path)
end

fun list-compare<A>(lst1 :: List<A>, lst2 :: List<A>) -> Boolean:
  doc: ```returns true when lst1 is "less than" lst2```
  cases (List<A>) lst1:
    | empty => is-link(lst2)
    | link(f1, r1) =>
      cases (List<A>) lst2:
        | empty => false
        | link(f2, r2) =>
          (f1 < f2) or 
          ((f1 == f2) and list-compare(r1, r2))
      end
  end
end

fun loc-path-comparator(a :: HeapPath, b :: HeapPath) -> Boolean:
  doc: ```returns true if the first LocPath is less than or equal to the second
       LocPath in terms of distance from the start```
  if a.distance-from-start == b.distance-from-start:
    list-compare(a.path, b.path)
  else:
    a.distance-from-start < b.distance-from-start
  end
end

## IMPLEMENTATION

fun dijkstra(start :: Name, graph :: Graph) -> Set<Path>:

  fun helper(queue :: Heap<HeapPath>, finalized-paths :: StringDict<Path>) -> Set<Path>:

    cases (Heap) queue:
      | mt =>
        finalized-paths.fold-keys(
          lam(key :: String, acc :: Set<Path>) -> Set<Path>:
            acc.add(finalized-paths.get-value(key))
          end,
          [set:])

      | node(_, _, _) =>
        min-heap-path = get-min(queue)
        current-name  = min-heap-path.name
        shadow queue = remove-min(queue, loc-path-comparator)

        # Since the queue allows for duplicate LocPaths to be stored in it
        # (see `update-estimates-in-heap`), check to see if the distance
        # estimate for this LocPath has already been finalized:
        if finalized-paths.has-key(current-name):
          # If it has been finalized, ignore it and recur:
          helper(queue, finalized-paths)
        else:
          # If the Loc's distance from the root has not been finalized,
          # finalize it with this LocPath by adding it to the
          # finalized-locpaths StringDict:
          shadow finalized-paths = finalized-paths.set(current-name, min-heap-path.path)

          # Update the queue's "distance from start" estimates for all of the
          # neighbors connected to the Loc in the LocPath current-path:
          shadow queue = update-estimates-in-heap(queue, graph, min-heap-path, finalized-paths)

          # Recur on the updated queue and updated finalized paths!
          helper(queue, finalized-paths)
        end
    end
  end

  if graph.names().member(start):
    start-queue     = node(heap-path(start, 0, [list: start]), mt, mt)
    start-finalized = [string-dict:]

    helper(start-queue, start-finalized)
  else:
    [set: ]
  end
end

fun update-estimates-in-heap(
    queue :: Heap<HeapPath>,
    graph :: Graph,
    heap-path-to-update-with :: HeapPath,
    finalized-paths :: StringDict<Path>)
  -> Heap<HeapPath>:
  doc: ```consumes a Heap queue representing the current state of the Heap, a
         StringDict<LocPath> finalized-locpaths where each of its keys
         correspond to the names of the Locs whose shortest distances from the
         start are known, and a LocPath path-loc-to-update-with that contains
         the Loc whose neighbors's estimates need to be updated; returns the
         queue containing the new LocPath estimates```

  current-place = graph.get(heap-path-to-update-with.name)
  current-dist  = heap-path-to-update-with.distance-from-start
  current-path  = heap-path-to-update-with.path
  neighbors     = current-place.neighbors.to-list()
  distances     = neighbors.map(lam(neighbor-name):
      neighbor = graph.get(neighbor-name)
      neighbor.position.distance(current-place.position)
    end)

  # Iterate through each of current-loc's neighbors and "update" their LocPath
  # estimates in our Heap queue:
  for fold2(q from queue, neighbor-name from neighbors, dist from distances):
    if finalized-paths.has-key(neighbor-name):
      # If a LocPath with the same name as the neighbor has already been
      # finalized, don't update the queue:
      q
    else:
      # Otherwise, update the queue with the new distance parameters. If a
      # neighbor has an existing LocPath in the queue, we're not actually
      # going to "update" that LocPath's distance estimate--rather, we're
      # simply going to insert a new LocPath into the queue as long as a
      # LocPath for that location hasn't been finalized yet. This keeps our
      # queue operation efficiency in sub-linear time!

      new-heap-path  = heap-path(
        neighbor-name,
        current-dist + dist,
        link(neighbor-name, current-path))

      insert(new-heap-path, q, loc-path-comparator)
    end
  end
end

fun campus-tour(tours :: Set<Tour>, start-position :: Point, campus-data :: Graph) -> Path:
  
  fun accumulate-tour-path(
    starting-place :: Place,
    remaining-tour-stops :: List<String>,
    tour-path :: List<String>)
  -> List<String>:
    doc: ```builds a List<String> containing the names of the Locs, in order, that
       must be visited in terms of the `campus-tour` spec```

    # Build a shortest-path tree List<Path> from the given Loc using `dijkstra`.
    # This gets reversed because this function was written assuming
    # that the first entry of paths is the starting location,
    # and the last is the endpoint.
    paths = dijkstra(starting-place.name, campus-data).to-list()

    # Filter out Paths that are not in the List<String> remaining-tour-stops:
    tour-stop-paths = paths.filter({(path): remaining-tour-stops.member(path.first)})

    # Convert paths to places:
    tour-stop-places :: List<Place> = tour-stop-paths.map({(path): campus-data.get(path.first)})

    # Get path to next place
    cases (Option) find-next-path(campus-data, tour-stop-paths):
      | none => tour-path
      | some(next-path) =>
        # Get next place:
        next-place = campus-data.get(next-path.first)

        # Update the accumulated List<String> tour-path:
        updated-tour-path = next-path.append(tour-path.rest)

        # Remove the next place from the remaining stops list
        shadow remaining-tour-stops = remaining-tour-stops.filter(next-place.name <> _)

        # Recur!
        accumulate-tour-path(
          next-place,
          remaining-tour-stops,
          updated-tour-path)
    end
  end

  tour-stop-names = lists.distinct(fold(
      lam(acc :: List<String>, t :: Tour) -> List<String>:
        acc.append(t.stops.to-list())
      end, empty, tours.to-list()))

  cases (List) tour-stop-names:
    | empty => empty
    | link(loc-name, _) =>
      # Extract all of the Locs hidden inside of the `get-loc` function:
      places = campus-data.names().to-list().map(campus-data.get(_))

      # Find the closest valid starting location
      start-place = find-closest-location(places, campus-data, start-position)

      # Check if the place we're starting at is one of the tour stops. If so, remove it:
      remaining-tour-stops = tour-stop-names.filter(start-place.name <> _)

      accumulate-tour-path(start-place, remaining-tour-stops, [list: start-place.name])
  end
end

fun find-closest-location(places :: List<Place>, graph :: Graph, pos :: Point) -> Place:
  cases (List) places:
    | empty => raise("no locations")
    | link(f, r) => 
      r.foldl(
        lam(current-closest :: Place, p :: Place) -> Place:
          place-dist   = p.position.distance(pos)
          current-dist = current-closest.position.distance(pos)

          if place-dist == current-dist:
            if p.name < current-closest.name:
              p
            else:
              current-closest
            end
          else:
            if place-dist < current-dist:
              p
            else:
              current-closest
            end
          end
        end, f)
  end
end

fun path-length(path :: Path, graph :: Graph) -> Number:
  doc: ```Finds the length of a path.```
  cases (List) path:
    | empty => 0
    | link(f, r) =>
      fold2({(acc, from-loc, to-loc):
          acc + graph.get(from-loc).distance(graph.get(to-loc))},
        0, path, r)
  end
end

fun find-next-path(graph :: Graph, paths :: List<Path>) -> Option<Path>:
  doc: ```Finds the next location in a tour path by path distance.```
  cases (List) paths:
    | empty => none
    | link(f, r) => 
      path = for fold(best-path from f, path from r):
        if path-length(best-path, graph) > path-length(path, graph):
          path
        else:
          best-path
        end
      end
      some(path)
  end
end

########################################
## Priority Queue Heap Implementation ##
########################################

data Heap<T>:
  | mt
  | node(value :: T, left :: Heap<T>, right :: Heap<T>)
end

data Amputated<T>:
  | elt-and-heap(elt :: T, heap :: Heap<T>)
end

fun insert<T>(elt :: T, heap :: Heap<T>, cmp :: (T, T -> Boolean)) -> Heap<T>:
  doc: ```Adds an element to a heap, comparing elements with a comparator that returns true if
       the first element is leq the second```

  cases (Heap) heap:
    | mt => node(elt, mt, mt)
    | node(v, l, r) =>
      if cmp(v, elt):
        node(v, insert(elt, r, cmp), l)
      else:
        node(elt, insert(v, r, cmp), l)
      end
  end
end

fun get-min<T>(h :: Heap<T>%(is-node)) -> HeapPath<T>:
  doc: ```consumes a balanced, non-empty Heap h and produces the smallest
       element in h```
  h.value
end

fun remove-min<T>(h :: Heap<T>%(is-node), cmp :: (T, T -> Boolean)) -> Heap<T>:
  doc: ```consumes a balanced, non-empty Heap h and returns it with the smallest element removed```

  leftmost-amp = amputate-bottom-left(h)
  cases (Heap) leftmost-amp.heap:
    | mt => mt
    | node(val, lh, rh) =>
      updated-heap = node(leftmost-amp.elt, lh, rh)
      reorder(rebalance(updated-heap), cmp)
  end
end

fun amputate-bottom-left<T>(h :: Heap<T>%(is-node)) -> Amputated<T>:
  doc: ```Given a Heap h, produes an Amputated that contains the bottom-left
       element of h, and h with the bottom-left element removed.```

  cases (Heap) h.left:
    | mt => elt-and-heap(h.value, mt)
    | node(_, _, _) =>
      rec-amputated  = amputate-bottom-left(h.left)
      remaining-heap = node(h.value, rec-amputated.heap, h.right)
      elt-and-heap(rec-amputated.elt, remaining-heap)
  end
end

fun rebalance<T>(h :: Heap<T>) -> Heap<T>:
  doc: ```Given a Heap h, switches all children along the leftmost path```

  cases (Heap) h:
    | mt => mt
    | node(val, lh, rh) => node(val, rh, rebalance(lh))
  end
end

fun reorder<T>(h :: Heap<T>, cmp :: (T, T -> Boolean)) -> Heap<T>:
  doc: ```Given a Heap h, where only the top node is misplaced, produces a Heap
       with the same elements but in proper order.```

  cases (Heap) h:
    | mt => mt
    | node(val, lh, rh) =>

      cases (Heap) lh:
        | mt => node(val, mt, mt)
        | node(lval, llh, lrh) =>

          cases (Heap) rh:
            | mt =>
              if cmp(val, lval):
                node(val, node(lval, mt, mt), mt)
              else:
                node(lval, node(val, mt, mt), mt)
              end

            | node(rval, rlh, rrh) =>
              if cmp(lval, rval):
                if cmp(val, lval):
                  h
                else:
                  node(lval, reorder(node(val, llh, lrh), cmp), rh)
                end
              else:
                if cmp(val, rval):
                  h
                else:
                  node(rval, lh, reorder(node(val, rlh, rrh), cmp))
                end
              end
          end
      end
  end
end


# ---- tests ----
check "dijkstra":
  block:
    # dijkstra works on a graph containing a single Loc
    test-graph = to-graph([set: place("A", point(0, 0), empty-set)])
    dijkstra("A", test-graph) is [set: [list: "A"]]
  end
  block:
    # dijkstra-one-path
    # graph with only one possible path
    dijkstra("tg-loc-A", to-graph(
        [set: tg-loc-A,tg-loc-B,tg-loc-C,tg-loc-D,tg-loc-E]))
      is [set: [list: "tg-loc-E", "tg-loc-D", "tg-loc-C", "tg-loc-B", "tg-loc-A"],
      [list: "tg-loc-D", "tg-loc-C", "tg-loc-B", "tg-loc-A"],
      [list: "tg-loc-C", "tg-loc-B", "tg-loc-A"],
      [list: "tg-loc-B", "tg-loc-A"],
      [list: "tg-loc-A"]]
  end
  block:
    # dijkstra returns the empty set if the input node is not in the graph
    dijkstra("A", to-graph(
        [set: tg-loc-A,tg-loc-B,tg-loc-C,tg-loc-D,tg-loc-E])) is empty-set
  end
  block:
    # dijkstra handles two nodes at the same place properly
    tg-loc-a = place("a", point(0, 0), [set: "b"])
    tg-loc-b = place("b", point(0, 0), [set: "a"])
    dijkstra("a", to-graph([set: tg-loc-a, tg-loc-b]))
      is [set: [list: "a"], [list: "b", "a"]]
  end
  block:
    # dijkstra should work even if a node's name is the empty string
    tg-loc-a = place("tg-loc-a", point(0, 0), [set: "tg-loc-b"])
    tg-loc-b = place("tg-loc-b", point(0, 1), [set: "tg-loc-a", "tg-loc-c"])
    tg-loc-c = place("tg-loc-c", point(0, 2), [set: "tg-loc-b", "tg-loc-d"])
    tg-loc-d = place("tg-loc-d", point(0, 3), [set: "tg-loc-c", ""])
    tg-loc-empty = place("", point(0, 4), [set: "tg-loc-d"])
    dijkstra("tg-loc-a", to-graph(
        [set: tg-loc-a,tg-loc-b,tg-loc-c,tg-loc-d,tg-loc-empty]))
      is [set: [list: "", "tg-loc-d", "tg-loc-c", "tg-loc-b", "tg-loc-a"],
      [list: "tg-loc-d", "tg-loc-c", "tg-loc-b", "tg-loc-a"],
      [list: "tg-loc-c", "tg-loc-b", "tg-loc-a"],
      [list: "tg-loc-b", "tg-loc-a"],
      [list: "tg-loc-a"]]
  end
  block:
    # dijkstra can handle fully connected and negative vertices
    tg-loc-a = place("tg-loc-a", point(0, -1), [set: "tg-loc-b", "tg-loc-c"])
    tg-loc-b = place("tg-loc-b", point(0, 0), [set: "tg-loc-c", "tg-loc-a"])
    tg-loc-c = place("tg-loc-c", point(1, 0), [set: "tg-loc-b", "tg-loc-a"])
    dijkstra("tg-loc-b", to-graph([set: tg-loc-a, tg-loc-b, tg-loc-c]))
      is [set: [list: "tg-loc-b"],
      [list: "tg-loc-a", "tg-loc-b"],
      [list: "tg-loc-c", "tg-loc-b"]]
  end
  block:
    # dijkstra can handle large distances
    tg-loc-a = place("a", point(0, 0), [set: "b"])
    tg-loc-b = place("b", point(10000, 10000), [set: "a"])
    dijkstra("a", to-graph([set: tg-loc-a, tg-loc-b]))
      is [set: [list: "a"],
      [list: "b", "a"]]
  end
  block:
    # dijkstra uses manhattan distance instead of euclidean distance.
    places = [set:
      place("Start", point(1, 1), [set: "Euc", "Man"]),
      place("Euc", point(6, 6), [set: "Start", "End"]),
      place("Man", point(-7, 2), [set: "Start", "End"]),
      place("End", point(-1, 4), [set: "Euc", "Man"])]
    my-graph = to-graph(places)
    dijkstra("Start", my-graph).member([list: "End", "Man", "Start"]) is true
  end
end

check "campus-tour":
  block:
    # campus-tour outputs an empty List if the List<Tour> tours-list is       empty
    test-graph =
      [set:
        place("A", point(0, 1),  [set: "B"]),
        place("B", point(1, 0),  [set: "A", "C"]),
        place("C", point(0, -1), [set: "B", "D"]),
        place("D", point(-1, 0), [set: "C"])]
    campus-map = to-graph(test-graph)
    campus-tour(empty-set, point(0, 1), campus-map) is empty
  end
  block:
    # campus-tour handles a Tour of a single place and a graph of a        single place
    test-tours = [set: tour("Tour", [set: "A"])]
    test-graph =
      [set:
        place("A", point(0, 0), empty-set)]
    campus-map = to-graph(test-graph)
    campus-tour(test-tours, point(0, 0), campus-map) is [list: "A"]
  end
  block:
    # campus-tour handles a Tour of a single Loc and a graph of multiple Locs
    test-tours = [set: tour("Tour", [set: "A"])]
    test-graph =
      [set:
        place("A", point(0, 1),  [set: "B"]),
        place("B", point(1, 0),  [set: "A", "C"]),
        place("C", point(0, -1), [set: "B", "D"]),
        place("D", point(-1, 0), [set: "C"])]
    campus-map = to-graph(test-graph)
    campus-tour(test-tours, point(0, 1), campus-map)  is [list: "A"]
    campus-tour(test-tours, point(1, 0), campus-map)  is [list: "A", "B"]
    campus-tour(test-tours, point(0, -1), campus-map) is [list: "A", "B", "C"]
    campus-tour(test-tours, point(-1, 0), campus-map) 
      is [list: "A", "B", "C", "D"]
  end
  block:
    # campus-tour outputs an empty List if the List<Tour> tours-list only       contains Tours t
    single-empty-tour =
      [set:
        tour("Empty 1", empty-set)]
    multiple-empty-tours =
      [set:
        tour("Empty 1", empty-set),
        tour("Empty 2", empty-set),
        tour("Empty 3", empty-set)]
    test-graph =
      [set:
        place("A", point(0, 1),  [set: "B"]),
        place("B", point(1, 0),  [set: "A", "C"]),
        place("C", point(0, -1), [set: "B", "D"]),
        place("D", point(-1, 0), [set: "C"])]
    campus-map = to-graph(test-graph)
    campus-tour(single-empty-tour, point(0, 1), campus-map) is empty
    campus-tour(multiple-empty-tours, point(0, 1), campus-map) is empty
  end
  block:
    # campus-tour outputs correct path even if start-lat and start-lon don't       match the lat
    test-tours = [set: tour("Tour", [set: "D"])]
    test-graph =
      [set:
        place("A", point(0, 1),  [set: "B"]),
        place("B", point(1, 0),  [set: "A", "C"]),
        place("C", point(0, -1), [set: "B", "D"]),
        place("D", point(-1, 0), [set: "C"])]
    campus-map = to-graph(test-graph)
    campus-tour(test-tours, point(0, 2), campus-map) is [list: "D", "C", "B", "A"]
    campus-tour(test-tours, point(0, -2), campus-map) is [list: "D", "C"]
    campus-tour(test-tours, point(-2, 0), campus-map) is [list: "D"]
  end
  block:
    # campus-tour outputs correct path for a List of Tours that all have       different Loc nam
    test-tours =
      [set:
        tour("Tour 1", [set: "A"]),
        tour("Tour 2", [set: "D"])]
    test-graph =
      [set:
        place("A", point(0, 1),  [set: "B"]),
        place("B", point(1, 0),  [set: "A", "C"]),
        place("C", point(0, -1), [set: "B", "D"]),
        place("D", point(-1, 0), [set: "C"])]
    campus-map = to-graph(test-graph)
    campus-tour(test-tours, point(1, 0), campus-map)
      is [list: "D", "C", "B", "A", "B"]
  end
  block:
    # campus-tour outputs correct path when a loc has an empty string as a name
    test-tours =
      [set:
        tour("Tour 1", [set: ""]),
        tour("Tour 2", [set: "D"])]
    test-graph =
      [set:
        place("", point(0, 1),  [set: "B"]),
        place("B", point(1, 0),  [set: "", "C"]),
        place("C", point(0, -1), [set: "B", "D"]),
        place("D", point(-1, 0), [set: "C"])]
    campus-map = to-graph(test-graph)
    campus-tour(test-tours, point(1, 0), campus-map)
      is [list: "D", "C", "B", "", "B"]
  end
  block:
    # campus-tour outputs correct path even if there are duplicate Loc names       across Tours 
    test-tours =
      [set:
        tour("Tour 1", [set: "A"]),
        tour("Tour 2", [set: "D"]),
        tour("Tour 3", [set: "A"])]
    test-graph =
      [set:
        place("A", point(0, 1),  [set: "B"]),
        place("B", point(1, 0),  [set: "A", "C"]),
        place("C", point(0, -1), [set: "B", "D"]),
        place("D", point(-1, 0), [set: "C"])]
    campus-map = to-graph(test-graph)
    campus-tour(test-tours, point(1, 0), campus-map)
      is [list: "D", "C", "B", "A", "B"]
  end
  block:
    # campus-tour chooses starting position based on the closest Loc on the       graph to start
    test-tours = [set: tour("Tour", [set: "A"])]
    test-graph =
      [set:
        place("A", point(0, 0),  [set: "B"]),
        place("B", point(1, 0),  [set: "A"])]
    campus-map = to-graph(test-graph)
    campus-tour(test-tours, point(2, 0), campus-map) is [list: "A", "B"]
  end
  block:
    # campus-tour uses shortest path distance to choose next Loc to visit,       not longitude a
    test-tours = [set: tour("Tour", [set: "B", "A", "C"])]
    test-graph =
      [set:
        place("A", point(2, 0),  [set: "B"]),
        place("B", point(0, 0),  [set: "A", "C"]),
        place("C", point(1, 0),  [set: "B"])]
    campus-map = to-graph(test-graph)
    campus-tour(test-tours, point(0, 0), campus-map) is [list: "A", "B", "C", "B"]
    campus-tour(test-tours, point(-1, 0), campus-map) 
      is [list: "A", "B", "C", "B"]
  end
  block:
    # campus-tour works on graphs where all nodes are connected to at most       one other node 
    tours-list =
      [set:
        tour("Backtracking Party", [set: "A", "B", "C", "D", "E", "F", "G"])]
    test-graph =
      [set:
        place("A", point(0, 0),
          [set: "B", "C", "D", "E", "F", "G"]),
        place("B", point(1, 0), [set: "A"]),
        place("C", point(2, 0), [set: "A"]),
        place("D", point(3, 0), [set: "A"]),
        place("E", point(4, 0), [set: "A"]),
        place("F", point(5, 0), [set: "A"]),
        place("G", point(6, 0), [set: "A"])]
    campus-map = to-graph(test-graph)
    campus-tour(tours-list, point(0, 0), campus-map)
      is [list: "G", "A", "F", "A", "E", "A", "D", "A", "C", "A", "B", "A"]
  end
  block:
    # campus-tour outputs one of either acceptable output for graphs with       two valid answer
    tours-list = [set: 
      tour("B", [set: "B"]),
      tour("C", [set: "C"])]
    test-graph = [set:
      place("A", point(0, 0), [set: "B", "C"]),
      place("B", point(1, 0), [set: "A"]),
      place("C", point(1, 0), [set: "A"])]
    campus-map = to-graph(test-graph)
  
    valid-tours = [list: 
      [list: "C", "A", "B", "A"],
      [list: "B", "A", "C", "A"]]
    valid-tours.member(campus-tour(tours-list, point(0, 0), campus-map)) is true
  end
  block:
    # campus-tour outputs one of any acceptable output for graphs with       many valid answers
    tours-list = [set: 
      tour("B", [set: "B"]),
      tour("C", [set: "C"]),
      tour("D", [set: "D"])]
    test-graph = [set:
      place("A", point(0, 0), [set: "B", "C", "D"]),
      place("B", point(1, 0), [set: "A"]),
      place("C", point(1, 0), [set: "A"]),
      place("D", point(1, 0), [set: "A"])]
    campus-map = to-graph(test-graph)
  
    valid-tours = [list: 
      [list: "D", "A", "C", "A", "B", "A"],
      [list: "C", "A", "D", "A", "B", "A"],
      [list: "D", "A", "B", "A", "C", "A"],
      [list: "B", "A", "D", "A", "C", "A"],
      [list: "C", "A", "B", "A", "D", "A"],
      [list: "B", "A", "C", "A", "D", "A"]]
    valid-tours.member(campus-tour(tours-list, point(0, 0), campus-map)) is true
  end
  block:
    # campus-tour make sure that they are choosing next place by       path-length not by euclid
    places = [set:
      place("A", point(0, 0), [set: "B"]),
      place("B", point(1, 0), [set: "A", "C"]),
      place("C", point(2, 0), [set: "B", "D"]),
      place("D", point(2, 1), [set: "C", "E"]),
      place("E", point(1, 1), [set: "D", "F"]),
      place("F", point(0, 1), [set: "E"])]
    tours = [set:
      tour("A", [set: "A", "C", "D", "F"])]
    my-graph = to-graph(places)
    campus-tour(tours, point(0, 0), my-graph) is [list: "F", "E", "D", "C", "B", "A"]
  end
end
