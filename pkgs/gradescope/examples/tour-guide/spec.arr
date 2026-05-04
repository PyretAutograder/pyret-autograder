use context autograder-spec
provide: spec end

include graders

fun build-graders(path :: String):
  [list:

    mk-wheat("tour-guide-wheat-1a", empty, path, "tour-guide/tour-guide-wheat.arr", "dijkstra", 1),
    mk-wheat("tour-guide-wheat-1b", empty, path, "tour-guide/tour-guide-wheat.arr", "campus-tour", 1),

    mk-wheat("tour-guide-wheat-2a", empty, path, "tour-guide/tour-guide-wheat-2.arr", "dijkstra", 1),
    mk-wheat("tour-guide-wheat-2b", empty, path, "tour-guide/tour-guide-wheat-2.arr", "campus-tour", 1),

    mk-chaff("tour-guide-chaff-1a", empty, path, "tour-guide/tour-guide-chaff-campus-tour-chooses-starting-point-from-tour-stops-not-whole-graph.arr", "dijkstra", 1),
    mk-chaff("tour-guide-chaff-1b", empty, path, "tour-guide/tour-guide-chaff-campus-tour-chooses-starting-point-from-tour-stops-not-whole-graph.arr", "campus-tour", 1),

    mk-chaff("tour-guide-chaff-2a", empty, path, "tour-guide/tour-guide-chaff-campus-tour-errors-if-path-revisits-places.arr", "dijkstra", 1),
    mk-chaff("tour-guide-chaff-2b", empty, path, "tour-guide/tour-guide-chaff-campus-tour-errors-if-path-revisits-places.arr", "campus-tour", 1),

    mk-chaff("tour-guide-chaff-3a", empty, path, "tour-guide/tour-guide-chaff-campus-tour-errors-on-non-spanning-tour.arr", "dijkstra", 1),
    mk-chaff("tour-guide-chaff-3b", empty, path, "tour-guide/tour-guide-chaff-campus-tour-errors-on-non-spanning-tour.arr", "campus-tour", 1),

    mk-chaff("tour-guide-chaff-4a", empty, path, "tour-guide/tour-guide-chaff-campus-tour-errors-when-tour-contains-no-stops.arr", "dijkstra", 1),
    mk-chaff("tour-guide-chaff-4b", empty, path, "tour-guide/tour-guide-chaff-campus-tour-errors-when-tour-contains-no-stops.arr", "campus-tour", 1),

    mk-chaff("tour-guide-chaff-5a", empty, path, "tour-guide/tour-guide-chaff-campus-tour-errors-when-tours-overlap.arr", "dijkstra", 1),
    mk-chaff("tour-guide-chaff-5b", empty, path, "tour-guide/tour-guide-chaff-campus-tour-errors-when-tours-overlap.arr", "campus-tour", 1),

    mk-chaff("tour-guide-chaff-6a", empty, path, "tour-guide/tour-guide-chaff-campus-tour-fails-on-node-named-empty-string.arr", "dijkstra", 1),
    mk-chaff("tour-guide-chaff-6b", empty, path, "tour-guide/tour-guide-chaff-campus-tour-fails-on-node-named-empty-string.arr", "campus-tour", 1),

    mk-chaff("tour-guide-chaff-7a", empty, path, "tour-guide/tour-guide-chaff-campus-tour-fails-when-input-tour-set-is-empty.arr", "dijkstra", 1),
    mk-chaff("tour-guide-chaff-7b", empty, path, "tour-guide/tour-guide-chaff-campus-tour-fails-when-input-tour-set-is-empty.arr", "campus-tour", 1),

    mk-chaff("tour-guide-chaff-8a", empty, path, "tour-guide/tour-guide-chaff-campus-tour-fails-with-one-stop.arr", "dijkstra", 1),
    mk-chaff("tour-guide-chaff-8b", empty, path, "tour-guide/tour-guide-chaff-campus-tour-fails-with-one-stop.arr", "campus-tour", 1),

    mk-chaff("tour-guide-chaff-9a", empty, path, "tour-guide/tour-guide-chaff-dijkstra-case-insensitive.arr", "dijkstra", 1),
    mk-chaff("tour-guide-chaff-9b", empty, path, "tour-guide/tour-guide-chaff-dijkstra-case-insensitive.arr", "campus-tour", 1),
    

    mk-chaff("tour-guide-chaff-10a", empty, path, "tour-guide/tour-guide-chaff-dijkstra-errors-on-fully-connected-graph.arr", "dijkstra", 1),
    mk-chaff("tour-guide-chaff-10b", empty, path, "tour-guide/tour-guide-chaff-dijkstra-errors-on-fully-connected-graph.arr", "campus-tour", 1),
    

    mk-chaff("tour-guide-chaff-11a", empty, path, "tour-guide/tour-guide-chaff-dijkstra-errors-on-graph-missing-starting-node.arr", "dijkstra", 1),
    mk-chaff("tour-guide-chaff-11b", empty, path, "tour-guide/tour-guide-chaff-dijkstra-errors-on-graph-missing-starting-node.arr", "campus-tour", 1),
    

    mk-chaff("tour-guide-chaff-12a", empty, path, "tour-guide/tour-guide-chaff-dijkstra-errors-on-single-node-graphs.arr", "dijkstra", 1),
    mk-chaff("tour-guide-chaff-12b", empty, path, "tour-guide/tour-guide-chaff-dijkstra-errors-on-single-node-graphs.arr", "campus-tour", 1),
    

    mk-chaff("tour-guide-chaff-13a", empty, path, "tour-guide/tour-guide-chaff-dijkstra-errors-when-graph-contains-multiple-places-at-same-position.arr", "dijkstra", 1),
    mk-chaff("tour-guide-chaff-13b", empty, path, "tour-guide/tour-guide-chaff-dijkstra-errors-when-graph-contains-multiple-places-at-same-position.arr", "campus-tour", 1),
    

    mk-chaff("tour-guide-chaff-14a", empty, path, "tour-guide/tour-guide-chaff-dijkstra-fails-on-large-dimensions.arr", "dijkstra", 1),
    mk-chaff("tour-guide-chaff-14b", empty, path, "tour-guide/tour-guide-chaff-dijkstra-fails-on-large-dimensions.arr", "campus-tour", 1),
    

    mk-chaff("tour-guide-chaff-15a", empty, path, "tour-guide/tour-guide-chaff-dijkstra-fails-on-node-named-empty-string.arr", "dijkstra", 1),
    mk-chaff("tour-guide-chaff-15b", empty, path, "tour-guide/tour-guide-chaff-dijkstra-fails-on-node-named-empty-string.arr", "campus-tour", 1),
    

    mk-chaff("tour-guide-chaff-16a", empty, path, "tour-guide/tour-guide-chaff-dijkstra-fails-when-points-are-negative.arr", "dijkstra", 1),
    mk-chaff("tour-guide-chaff-16b", empty, path, "tour-guide/tour-guide-chaff-dijkstra-fails-when-points-are-negative.arr", "campus-tour", 1),
    

    mk-chaff("tour-guide-chaff-17a", empty, path, "tour-guide/tour-guide-chaff-euclidean-distance.arr", "dijkstra", 1),
    mk-chaff("tour-guide-chaff-17b", empty, path, "tour-guide/tour-guide-chaff-euclidean-distance.arr", "campus-tour", 1),
    ]

end

spec = build-graders("submission/assignment.arr")
