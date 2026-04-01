use context autograder-spec
provide: spec end

include graders

fun build-graders(path :: String):
  [list:
    mk-well-formed("wf", empty, path),
    mk-training-wheels("tw", [list: "wf"], path, false),
    mk-fn-def("docdiff-def", [list: "tw"], path, "overlap", 2),
    mk-self-test("docdiff-self-test", [list: "docdiff-def"], path, "overlap", 1),
    mk-test-diversity("docdiff-diversity", [list: "docdiff-def"], path, "overlap", 2, 2),
    mk-functional("docdiff-functional", [list: "docdiff-def"], path, "functionality.arr", "docdiff: functionality", 4, some("overlap")),
    mk-wheat("docdiff-wheat-1", [list: "docdiff-diversity"], path, "docdiff/wheat-1.arr", "overlap", 1),
    mk-wheat("docdiff-wheat-2", [list: "docdiff-diversity"], path, "docdiff/docdiff-wheat.arr", "overlap", 1),
    mk-wheat("docdiff-wheat-3", [list: "docdiff-diversity"], path, "docdiff/docdiff-wheat-2.arr", "overlap", 1),

    mk-chaff("docdiff-chaff-1", [list: "docdiff-diversity"], path, "docdiff/chaff-1.arr", "overlap", 1),
    mk-chaff("docdiff-chaff-2", [list: "docdiff-diversity"], path, "docdiff/docdiff-chaff-case-sensitive.arr", "overlap", 1),
    mk-chaff("docdiff-chaff-3", [list: "docdiff-diversity"], path, "docdiff/docdiff-chaff-normalize-by-min.arr", "overlap", 1),
    mk-chaff("docdiff-chaff-4", [list: "docdiff-diversity"], path, "docdiff/docdiff-chaff-normalized-by-larger-vector-mag.arr", "overlap", 1),
    mk-chaff("docdiff-chaff-5", [list: "docdiff-diversity"], path, "docdiff/docdiff-chaff-overlap-1-if-subsumed.arr", "overlap", 1),
    mk-chaff("docdiff-chaff-6", [list: "docdiff-diversity"], path, "docdiff/docdiff-chaff-overlap-always-0.arr", "overlap", 1),
    mk-chaff("docdiff-chaff-7", [list: "docdiff-diversity"], path, "docdiff/docdiff-chaff-overlap-in-ok.arr", "overlap", 1),
    ]
end

spec = build-graders("submission/assignment.arr")
