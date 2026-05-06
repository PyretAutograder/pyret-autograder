provide: dijkstra, campus-tour end

include file("submission/assignment-support.arr")

import string-dict as SD

# END HEADER
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

  fun helper(queue :: Heap<HeapPath>, finalized-paths :: SD.StringDict<Path>) -> Set<Path>:

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
  where:
    # works on graph containing single Loc
  test-graph-1 = to-graph([set: place("A", point(0, 0), empty-set)])
  dijkstra("A", test-graph-1) is [set: [list: "A"]]

  # graph w/only one possible path
  dijkstra("tg-loc-A", to-graph(
      [set: tg-loc-A,tg-loc-B,tg-loc-C,tg-loc-D,tg-loc-E]))
    is [set: [list: "tg-loc-E", "tg-loc-D", "tg-loc-C", "tg-loc-B", "tg-loc-A"],
    [list: "tg-loc-D", "tg-loc-C", "tg-loc-B", "tg-loc-A"],
    [list: "tg-loc-C", "tg-loc-B", "tg-loc-A"],
    [list: "tg-loc-B", "tg-loc-A"],
    [list: "tg-loc-A"]]

    # returns empty set if input node not in graph
  dijkstra("A", to-graph(
      [set: tg-loc-A,tg-loc-B,tg-loc-C,tg-loc-D,tg-loc-E])) is empty-set

      # handles 2 nodes at same place properly
  tg-loc-a = place("a", point(0, 0), [set: "b"])
  tg-loc-b = place("b", point(0, 0), [set: "a"])
  dijkstra("a", to-graph([set: tg-loc-a, tg-loc-b]))
    is [set: [list: "a"], [list: "b", "a"]]

    # shd work even if nodes' name is empty string
  tg-loc-1-a = place("tg-loc-1-a", point(0, 0), [set: "tg-loc-1-b"])
  tg-loc-1-b = place("tg-loc-1-b", point(0, 1), [set: "tg-loc-1-a", "tg-loc-1-c"])
  tg-loc-1-c = place("tg-loc-1-c", point(0, 2), [set: "tg-loc-1-b", "tg-loc-1-d"])
  tg-loc-1-d = place("tg-loc-1-d", point(0, 3), [set: "tg-loc-1-c", ""])
  tg-loc-1-empty = place("", point(0, 4), [set: "tg-loc-1-d"])
  dijkstra("tg-loc-1-a", to-graph(
      [set: tg-loc-1-a,tg-loc-1-b,tg-loc-1-c,tg-loc-1-d,tg-loc-1-empty]))
    is [set: [list: "", "tg-loc-1-d", "tg-loc-1-c", "tg-loc-1-b", "tg-loc-1-a"],
    [list: "tg-loc-1-d", "tg-loc-1-c", "tg-loc-1-b", "tg-loc-1-a"],
    [list: "tg-loc-1-c", "tg-loc-1-b", "tg-loc-1-a"],
    [list: "tg-loc-1-b", "tg-loc-1-a"],
    [list: "tg-loc-1-a"]]

    # can handle fully connected & negative vertices
  tg-loc-2-a = place("tg-loc-2-a", point(0, -1), [set: "tg-loc-2-b", "tg-loc-2-c"])
  tg-loc-2-b = place("tg-loc-2-b", point(0, 0), [set: "tg-loc-2-c", "tg-loc-2-a"])
  tg-loc-2-c = place("tg-loc-2-c", point(1, 0), [set: "tg-loc-2-b", "tg-loc-2-a"])
  dijkstra("tg-loc-2-b", to-graph([set: tg-loc-2-a, tg-loc-2-b, tg-loc-2-c]))
    is [set: [list: "tg-loc-2-b"],
    [list: "tg-loc-2-a", "tg-loc-2-b"],
    [list: "tg-loc-2-c", "tg-loc-2-b"]]

    # can handle long distances
  tg-loc-3-a = place("a", point(0, 0), [set: "b"])
  tg-loc-3-b = place("b", point(10000, 10000), [set: "a"])
  dijkstra("a", to-graph([set: tg-loc-3-a, tg-loc-3-b]))
    is [set: [list: "a"],
    [list: "b", "a"]]

    # uses manhattan distances instead of euclidean distance
  places = [set:
    place("Start", point(1, 1), [set: "Euc", "Man"]),
    place("Euc", point(6, 6), [set: "Start", "End"]),
    place("Man", point(-7, 2), [set: "Start", "End"]),
    place("End", point(-1, 4), [set: "Euc", "Man"])]
  my-graph = to-graph(places)
  dijkstra("Start", my-graph).member([list: "End", "Man", "Start"]) is true
end

fun update-estimates-in-heap(
    queue :: Heap<HeapPath>,
    graph :: Graph,
    heap-path-to-update-with :: HeapPath,
    finalized-paths :: SD.StringDict<Path>)
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
  where:
    # outputs empty List if tours-list is empty
  test-graph =
    [set:
      place("A", point(0, 1),  [set: "B"]),
      place("B", point(1, 0),  [set: "A", "C"]),
      place("C", point(0, -1), [set: "B", "D"]),
      place("D", point(-1, 0), [set: "C"])]
  campus-map = to-graph(test-graph)
  campus-tour(empty-set, point(0, 1), campus-map) is empty

  # handles Tour of single place & graph of single place
  test-tours = [set: tour("Tour", [set: "A"])]
  test-graph-1 =
    [set:
      place("A", point(0, 0), empty-set)]
  campus-map-1 = to-graph(test-graph-1)
  campus-tour(test-tours, point(0, 0), campus-map-1) is [list: "A"]

  # handles Tour of single Loc & graph of multiple Locs
  test-tours-2 = [set: tour("Tour", [set: "A"])]
  test-graph-2 =
    [set:
      place("A", point(0, 1),  [set: "B"]),
      place("B", point(1, 0),  [set: "A", "C"]),
      place("C", point(0, -1), [set: "B", "D"]),
      place("D", point(-1, 0), [set: "C"])]
  campus-map-2 = to-graph(test-graph-2)
  campus-tour(test-tours-2, point(0, 1), campus-map-2)  is [list: "A"]
  campus-tour(test-tours-2, point(1, 0), campus-map-2)  is [list: "A", "B"]
  campus-tour(test-tours-2, point(0, -1), campus-map-2) is [list: "A", "B", "C"]
  campus-tour(test-tours-2, point(-1, 0), campus-map-2) 
    is [list: "A", "B", "C", "D"]

    # outputs empty List if tours-list only contains Tours that have empty List in their .stops field
  single-empty-tour =
    [set:
      tour("Empty 1", empty-set)]
  multiple-empty-tours =
    [set:
      tour("Empty 1", empty-set),
      tour("Empty 2", empty-set),
      tour("Empty 3", empty-set)]
  test-graph-3 =
    [set:
      place("A", point(0, 1),  [set: "B"]),
      place("B", point(1, 0),  [set: "A", "C"]),
      place("C", point(0, -1), [set: "B", "D"]),
      place("D", point(-1, 0), [set: "C"])]
  campus-map-3 = to-graph(test-graph-3)
  campus-tour(single-empty-tour, point(0, 1), campus-map-3) is empty
  campus-tour(multiple-empty-tours, point(0, 1), campus-map-3) is empty

  # outputs correct path even if start-lat & start-lon don't match latitude & longitude of Loc in get-loc
  test-tours-4 = [set: tour("Tour", [set: "D"])]
  test-graph-4 =
    [set:
      place("A", point(0, 1),  [set: "B"]),
      place("B", point(1, 0),  [set: "A", "C"]),
      place("C", point(0, -1), [set: "B", "D"]),
      place("D", point(-1, 0), [set: "C"])]
  campus-map-4 = to-graph(test-graph-4)
  campus-tour(test-tours-4, point(0, 2), campus-map-4) is [list: "D", "C", "B", "A"]
  campus-tour(test-tours-4, point(0, -2), campus-map-4) is [list: "D", "C"]
  campus-tour(test-tours-4, point(-2, 0), campus-map-4) is [list: "D"]

   # outputs correct path for List of Tours that all have different Loc names
  test-tours-5 =
    [set:
      tour("Tour 1", [set: "A"]),
      tour("Tour 2", [set: "D"])]
  test-graph-5 =
    [set:
      place("A", point(0, 1),  [set: "B"]),
      place("B", point(1, 0),  [set: "A", "C"]),
      place("C", point(0, -1), [set: "B", "D"]),
      place("D", point(-1, 0), [set: "C"])]
  campus-map-5 = to-graph(test-graph-5)
  campus-tour(test-tours-5, point(1, 0), campus-map-5)
    is [list: "D", "C", "B", "A", "B"]

  # outputs correct path when loc has empty string as name
  test-tours-6 =
    [set:
      tour("Tour 1", [set: ""]),
      tour("Tour 2", [set: "D"])]
  test-graph-6 =
    [set:
      place("", point(0, 1),  [set: "B"]),
      place("B", point(1, 0),  [set: "", "C"]),
      place("C", point(0, -1), [set: "B", "D"]),
      place("D", point(-1, 0), [set: "C"])]
  campus-map-6 = to-graph(test-graph-6)
  campus-tour(test-tours-6, point(1, 0), campus-map-6)
    is [list: "D", "C", "B", "", "B"]

    # outputs correct path even if there are duplicate Loc names across Tours (ignores duplicates)
  test-tours-7 =
    [set:
      tour("Tour 1", [set: "A"]),
      tour("Tour 2", [set: "D"]),
      tour("Tour 3", [set: "A"])]
  test-graph-7 =
    [set:
      place("A", point(0, 1),  [set: "B"]),
      place("B", point(1, 0),  [set: "A", "C"]),
      place("C", point(0, -1), [set: "B", "D"]),
      place("D", point(-1, 0), [set: "C"])]
  campus-map-7 = to-graph(test-graph-7)
  campus-tour(test-tours-7, point(1, 0), campus-map-7)
    is [list: "D", "C", "B", "A", "B"]

   # chooses starting position based on closest Loc on graph to start-lat & start-lon (not necessarily Loc in List of Tours)
  test-tours-8 = [set: tour("Tour", [set: "A"])]
  test-graph-8 =
    [set:
      place("A", point(0, 0),  [set: "B"]),
      place("B", point(1, 0),  [set: "A"])]
  campus-map-8 = to-graph(test-graph-8)
  campus-tour(test-tours-8, point(2, 0), campus-map-8) is [list: "A", "B"]

  # uses shortest-path distance to choose next Loc to visit, not longitude & latitude
  test-tours-9 = [set: tour("Tour", [set: "B", "A", "C"])]
  test-graph-9 =
    [set:
      place("A", point(2, 0),  [set: "B"]),
      place("B", point(0, 0),  [set: "A", "C"]),
      place("C", point(1, 0),  [set: "B"])]
  campus-map-9 = to-graph(test-graph-9)
  campus-tour(test-tours-9, point(0, 0), campus-map-9) is [list: "A", "B", "C", "B"]
  campus-tour(test-tours-9, point(-1, 0), campus-map-9) 
    is [list: "A", "B", "C", "B"]


  # works on graphs where all nodes are connected to at most one other node except for single node
  tours-list-10 =
    [set:
      tour("Backtracking Party", [set: "A", "B", "C", "D", "E", "F", "G"])]
  test-graph-10 =
    [set:
      place("A", point(0, 0),
        [set: "B", "C", "D", "E", "F", "G"]),
      place("B", point(1, 0), [set: "A"]),
      place("C", point(2, 0), [set: "A"]),
      place("D", point(3, 0), [set: "A"]),
      place("E", point(4, 0), [set: "A"]),
      place("F", point(5, 0), [set: "A"]),
      place("G", point(6, 0), [set: "A"])]
  campus-map-10 = to-graph(test-graph-10)
  campus-tour(tours-list-10, point(0, 0), campus-map-10)
    is [list: "G", "A", "F", "A", "E", "A", "D", "A", "C", "A", "B", "A"]

    # outputs one of either acceptable output for graphs w/two valid answers
  tours-list-11 = [set: 
    tour("B", [set: "B"]),
    tour("C", [set: "C"])]
  test-graph-11 = [set:
    place("A", point(0, 0), [set: "B", "C"]),
    place("B", point(1, 0), [set: "A"]),
    place("C", point(1, 0), [set: "A"])]
  campus-map-11 = to-graph(test-graph-11)
  
  valid-tours = [list: 
    [list: "C", "A", "B", "A"],
    [list: "B", "A", "C", "A"]]
  valid-tours.member(campus-tour(tours-list-11, point(0, 0), campus-map-11)) is true

  # outputs one of any acceptable output for graphs w/many valid answers
  tours-list-12 = [set: 
    tour("B", [set: "B"]),
    tour("C", [set: "C"]),
    tour("D", [set: "D"])]
  test-graph-12 = [set:
    place("A", point(0, 0), [set: "B", "C", "D"]),
    place("B", point(1, 0), [set: "A"]),
    place("C", point(1, 0), [set: "A"]),
    place("D", point(1, 0), [set: "A"])]
  campus-map-12 = to-graph(test-graph-12)
  
  valid-tours-12 = [list: 
    [list: "D", "A", "C", "A", "B", "A"],
    [list: "C", "A", "D", "A", "B", "A"],
    [list: "D", "A", "B", "A", "C", "A"],
    [list: "B", "A", "D", "A", "C", "A"],
    [list: "C", "A", "B", "A", "D", "A"],
    [list: "B", "A", "C", "A", "D", "A"]]
  valid-tours-12.member(campus-tour(tours-list-12, point(0, 0), campus-map-12)) is true

  # make sure that they're choosing next place by path-length not by euclidean distance
  places-13 = [set:
    place("A", point(0, 0), [set: "B"]),
    place("B", point(1, 0), [set: "A", "C"]),
    place("C", point(2, 0), [set: "B", "D"]),
    place("D", point(2, 1), [set: "C", "E"]),
    place("E", point(1, 1), [set: "D", "F"]),
    place("F", point(0, 1), [set: "E"])]
  tours-13 = [set:
    tour("A", [set: "A", "C", "D", "F"])]
  my-graph-13 = to-graph(places-13)
  campus-tour(tours-13, point(0, 0), my-graph-13) is [list: "F", "E", "D", "C", "B", "A"]
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

