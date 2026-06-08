use context autograder-spec
provide: spec end

include graders

fun build-graders(path :: String):
  [list:
    mk-well-formed("wf", empty, path),

    mk-wheat("wheat-1-dijkstra",    [list: "wf"], path, "tour-guide/tour-guide-wheat.arr",   "dijkstra",    1),
    mk-wheat("wheat-1-campus-tour", [list: "wf"], path, "tour-guide/tour-guide-wheat.arr",   "campus-tour", 1),
    mk-wheat("wheat-2-dijkstra",    [list: "wf"], path, "tour-guide/tour-guide-wheat-2.arr", "dijkstra",    1),
    mk-wheat("wheat-2-campus-tour", [list: "wf"], path, "tour-guide/tour-guide-wheat-2.arr", "campus-tour", 1),

    mk-chaff("chaff-campus-tour-chooses-starting-point-from-tour-stops-not-whole-graph", [list: "wf"], path, "tour-guide/tour-guide-chaff-campus-tour-chooses-starting-point-from-tour-stops-not-whole-graph.arr", "campus-tour", 1),
    mk-chaff("chaff-campus-tour-errors-if-path-revisits-places", [list: "wf"], path, "tour-guide/tour-guide-chaff-campus-tour-errors-if-path-revisits-places.arr", "campus-tour", 1),
    mk-chaff("chaff-campus-tour-errors-on-non-spanning-tour", [list: "wf"], path, "tour-guide/tour-guide-chaff-campus-tour-errors-on-non-spanning-tour.arr", "campus-tour", 1),
    mk-chaff("chaff-campus-tour-errors-when-tour-contains-no-stops", [list: "wf"], path, "tour-guide/tour-guide-chaff-campus-tour-errors-when-tour-contains-no-stops.arr", "campus-tour", 1),
    mk-chaff("chaff-campus-tour-errors-when-tours-overlap", [list: "wf"], path, "tour-guide/tour-guide-chaff-campus-tour-errors-when-tours-overlap.arr", "campus-tour", 1),
    mk-chaff("chaff-campus-tour-fails-on-node-named-empty-string", [list: "wf"], path, "tour-guide/tour-guide-chaff-campus-tour-fails-on-node-named-empty-string.arr", "campus-tour", 1),
    mk-chaff("chaff-campus-tour-fails-when-input-tour-set-is-empty", [list: "wf"], path, "tour-guide/tour-guide-chaff-campus-tour-fails-when-input-tour-set-is-empty.arr", "campus-tour", 1),
    mk-chaff("chaff-campus-tour-fails-with-one-stop", [list: "wf"], path, "tour-guide/tour-guide-chaff-campus-tour-fails-with-one-stop.arr", "campus-tour", 1),
    mk-chaff("chaff-dijkstra-case-insensitive", [list: "wf"], path, "tour-guide/tour-guide-chaff-dijkstra-case-insensitive.arr", "dijkstra", 1),
    mk-chaff("chaff-dijkstra-errors-on-fully-connected-graph", [list: "wf"], path, "tour-guide/tour-guide-chaff-dijkstra-errors-on-fully-connected-graph.arr", "dijkstra", 1),
    mk-chaff("chaff-dijkstra-errors-on-graph-missing-starting-node", [list: "wf"], path, "tour-guide/tour-guide-chaff-dijkstra-errors-on-graph-missing-starting-node.arr", "dijkstra", 1),
    mk-chaff("chaff-dijkstra-errors-on-single-node-graphs", [list: "wf"], path, "tour-guide/tour-guide-chaff-dijkstra-errors-on-single-node-graphs.arr", "dijkstra", 1),
    mk-chaff("chaff-dijkstra-errors-when-graph-contains-multiple-places-at-same-position", [list: "wf"], path, "tour-guide/tour-guide-chaff-dijkstra-errors-when-graph-contains-multiple-places-at-same-position.arr", "dijkstra", 1),
    mk-chaff("chaff-dijkstra-fails-on-large-dimensions", [list: "wf"], path, "tour-guide/tour-guide-chaff-dijkstra-fails-on-large-dimensions.arr", "dijkstra", 1),
    mk-chaff("chaff-dijkstra-fails-on-node-named-empty-string", [list: "wf"], path, "tour-guide/tour-guide-chaff-dijkstra-fails-on-node-named-empty-string.arr", "dijkstra", 1),
    mk-chaff("chaff-dijkstra-fails-when-points-are-negative", [list: "wf"], path, "tour-guide/tour-guide-chaff-dijkstra-fails-when-points-are-negative.arr", "dijkstra", 1),
    mk-chaff("chaff-euclidean-distance", [list: "wf"], path, "tour-guide/tour-guide-chaff-euclidean-distance.arr", "dijkstra", 1),
  ]
end

spec = build-graders("submission/assignment.arr")
