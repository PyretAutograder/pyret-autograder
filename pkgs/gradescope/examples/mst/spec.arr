use context autograder-spec
provide: spec end

include graders

fun build-graders(path :: String):
  [list:
    mk-well-formed("wf", empty, path),

    mk-wheat("wheat-1-mst-kruskal",    [list: "wf"], path, "mst/mst-wheat.arr",   "mst-kruskal",    1),
    mk-wheat("wheat-1-mst-prim",       [list: "wf"], path, "mst/mst-wheat.arr",   "mst-prim",       1),
    mk-wheat("wheat-1-generate-input", [list: "wf"], path, "mst/mst-wheat.arr",   "generate-input", 1),
    mk-wheat("wheat-1-mst-cmp",        [list: "wf"], path, "mst/mst-wheat.arr",   "mst-cmp",        1),
    mk-wheat("wheat-1-sort-o-cle",     [list: "wf"], path, "mst/mst-wheat.arr",   "sort-o-cle",     1),

    mk-wheat("wheat-2-mst-kruskal",    [list: "wf"], path, "mst/mst-wheat-2.arr", "mst-kruskal",    1),
    mk-wheat("wheat-2-mst-prim",       [list: "wf"], path, "mst/mst-wheat-2.arr", "mst-prim",       1),
    mk-wheat("wheat-2-generate-input", [list: "wf"], path, "mst/mst-wheat-2.arr", "generate-input", 1),
    mk-wheat("wheat-2-mst-cmp",        [list: "wf"], path, "mst/mst-wheat-2.arr", "mst-cmp",        1),
    mk-wheat("wheat-2-sort-o-cle",     [list: "wf"], path, "mst/mst-wheat-2.arr", "sort-o-cle",     1),

    mk-chaff("chaff-kruskal-error-on-empty",     [list: "wf"], path, "mst/mst-chaff-kruskal-error-on-empty.arr",                "mst-kruskal", 1),
    mk-chaff("chaff-kruskal-fails-on-negative",  [list: "wf"], path, "mst/mst-chaff-kruskal-fails-on-negative-weight-graphs.arr", "mst-kruskal", 1),

    mk-chaff("chaff-prim-error-on-empty",        [list: "wf"], path, "mst/mst-chaff-prim-error-on-empty.arr",                   "mst-prim", 1),
    mk-chaff("chaff-prim-fails-on-negative",     [list: "wf"], path, "mst/mst-chaff-prim-fails-on-negative-weight-graphs.arr",  "mst-prim", 1),

    mk-chaff("chaff-generate-input-unconnected", [list: "wf"], path, "mst/mst-chaff-generate-input-produces-unconnected.arr",            "generate-input", 1),
    mk-chaff("chaff-generate-input-wrong-nodes", [list: "wf"], path, "mst/mst-chaff-generate-input-produces-wrong-number-of-nodes.arr",  "generate-input", 1),

    mk-chaff("chaff-mst-cmp-doesnt-check-edges",     [list: "wf"], path, "mst/mst-chaff-mst-cmp-doesnt-check-edges-present-in-graph.arr", "mst-cmp", 1),
    mk-chaff("chaff-mst-cmp-doesnt-check-connected", [list: "wf"], path, "mst/mst-chaff-mst-cmp-doesnt-check-if-connected.arr",           "mst-cmp", 1),
    mk-chaff("chaff-mst-cmp-doesnt-check-tree",      [list: "wf"], path, "mst/mst-chaff-mst-cmp-doesnt-check-if-tree.arr",                "mst-cmp", 1),
    mk-chaff("chaff-mst-cmp-set-equality",           [list: "wf"], path, "mst/mst-chaff-mst-cmp-set-equality.arr",                        "mst-cmp", 1),

    mk-chaff("chaff-sort-o-cle-always-passes",   [list: "wf"], path, "mst/mst-chaff-sort-o-cle-always-passes.arr",          "sort-o-cle", 1),
    mk-chaff("chaff-sort-o-cle-minimality",      [list: "wf"], path, "mst/mst-chaff-sort-o-cle-checks-for-minimality.arr",  "sort-o-cle", 1),
    mk-chaff("chaff-sort-o-cle-fails-on-empty",  [list: "wf"], path, "mst/mst-chaff-sort-o-cle-fails-to-check-empty.arr",   "sort-o-cle", 1),
  ]
end

spec = build-graders("submission/assignment.arr")
