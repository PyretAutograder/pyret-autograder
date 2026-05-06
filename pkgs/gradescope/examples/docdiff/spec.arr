use context autograder-spec
provide: spec end

include graders

fun build-graders(path :: String):
  [list:
    mk-wheat("docdiff-wheat-1", empty, path, "docdiff/wheat-1.arr", "overlap", 1),
    mk-wheat("docdiff-wheat-2", empty, path, "docdiff/docdiff-wheat.arr", "overlap", 1),
    mk-wheat("docdiff-wheat-3", empty, path, "docdiff/docdiff-wheat-2.arr", "overlap", 1),

    mk-chaff("docdiff-chaff-1", empty, path, "docdiff/chaff-1.arr", "overlap", 1),
    mk-chaff("docdiff-chaff-2", empty, path, "docdiff/docdiff-chaff-case-sensitive.arr", "overlap", 1),
    mk-chaff("docdiff-chaff-3", empty, path, "docdiff/docdiff-chaff-normalize-by-min.arr", "overlap", 1),
    mk-chaff("docdiff-chaff-4", empty, path, "docdiff/docdiff-chaff-normalized-by-larger-vector-mag.arr", "overlap", 1),
    mk-chaff("docdiff-chaff-5", empty, path, "docdiff/docdiff-chaff-overlap-1-if-subsumed.arr", "overlap", 1),
    mk-chaff("docdiff-chaff-6", empty, path, "docdiff/docdiff-chaff-overlap-always-0.arr", "overlap", 1),
    mk-chaff("docdiff-chaff-7", empty, path, "docdiff/docdiff-chaff-overlap-in-ok.arr", "overlap", 1),
    ]
end

spec = build-graders("submission/assignment.arr")
