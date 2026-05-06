
provide: dijkstra, campus-tour end
# END HEADER
#| chaff (mheller6, Sep 3, 2020):
    Dijkstra errors when a graph contains multiple nodes at the same location.
    Search CHAFF DIFFERENCE for source of error
|#

data HeapPath:
  | heap-path(name :: Name, distance-from-start :: Number, path :: Path)
end

fun loc-path-comparator(a :: HeapPath, b :: HeapPath) -> Boolean:
  doc: ```returns true if the first LocPath is less than or equal to the second
       LocPath in terms of distance from the start```

  if a.distance-from-start == b.distance-from-start:
    a.name < b.name
  else:
    a.distance-from-start < b.distance-from-start
  end
end

## IMPLEMENTATION

fun dijkstra(start :: Name, graph :: Graph) -> Set<Path> block:

  fun helper(queue :: Heap<HeapPath>, finalized-paths :: SD.StringDict<Path>) -> Set<Path>:

    cases (Heap) queue:
      | mt =>
        finalized-paths.fold-keys(
          lam(key :: String, acc :: Set<Path>) -> Set<Path>:
            acc.add(finalized-paths.get-value(key))
          end,
          [list-set:])

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
          # finalized-locpaths SD.StringDict:
          shadow finalized-paths = finalized-paths.set(current-name, min-heap-path.path)

          # Update the queue's "distance from start" estimates for all of the
          # neighbors connected to the Loc in the LocPath current-path:
          shadow queue = update-estimates-in-heap(queue, graph, min-heap-path, finalized-paths)

          # Recur on the updated queue and updated finalized paths!
          helper(queue, finalized-paths)
        end
    end
  end
  
  graph-points = graph.names().to-list().map(graph.get(_)).map(_.position)

  # CHAFF DIFFERENCE
  when graph-points.length() <> lists.distinct(graph-points).length():
    raise("multiple nodes at the same location")
  end

  if graph.names().member(start):
    start-queue     = node(heap-path(start, 0, [list: start]), mt, mt)
    start-finalized = [string-dict:]

    helper(start-queue, start-finalized)
  else:
    empty-set
  end
end

fun update-estimates-in-heap(
    queue :: Heap<HeapPath>,
    graph :: Graph,
    heap-path-to-update-with :: HeapPath,
    finalized-paths :: SD.StringDict<Path>)
  -> Heap<HeapPath>:
  doc: ```consumes a Heap queue representing the current state of the Heap, a
         SD.StringDict<LocPath> finalized-locpaths where each of its keys
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

  tour-stop-names =lists.distinct(fold(
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
