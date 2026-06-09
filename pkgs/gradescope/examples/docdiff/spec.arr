use context autograder-spec
provide: spec end

include graders

fun build-graders(path :: String):
  [list:
    mk-well-formed("wf", empty, path),

    mk-wheat("wheat-1-overlap", [list: "wf"], path, "docdiff/docdiff-wheat.arr",   "overlap", 1),
    mk-wheat("wheat-2-overlap", [list: "wf"], path, "docdiff/docdiff-wheat-2.arr", "overlap", 1),

    mk-chaff("chaff-always-0",                       [list: "wf"], path, "docdiff/chaff-1.arr",                                          "overlap", 1),
    mk-chaff("chaff-overlap-always-0",               [list: "wf"], path, "docdiff/docdiff-chaff-overlap-always-0.arr",                   "overlap", 1),
    mk-chaff("chaff-case-sensitive",                 [list: "wf"], path, "docdiff/docdiff-chaff-case-sensitive.arr",                     "overlap", 1),
    mk-chaff("chaff-normalize-by-min",               [list: "wf"], path, "docdiff/docdiff-chaff-normalize-by-min.arr",                   "overlap", 1),
    mk-chaff("chaff-normalized-by-larger-vector-mag", [list: "wf"], path, "docdiff/docdiff-chaff-normalized-by-larger-vector-mag.arr",   "overlap", 1),
    mk-chaff("chaff-overlap-1-if-subsumed",          [list: "wf"], path, "docdiff/docdiff-chaff-overlap-1-if-subsumed.arr",              "overlap", 1),
  ]
end

spec = build-graders("submission/assignment.arr")
