use context autograder-spec
provide: spec end

include graders

fun build-graders(path :: String):
  [list:
    mk-well-formed("wf", empty, path),
    mk-training-wheels("tw", [list: "wf"], path, false),
    mk-fn-def("median-def", [list: "tw"], path, "median", 1),
    mk-self-test("median-self-test", [list: "median-def"], path, "median", 1),
    mk-test-diversity("median-diversity", [list: "median-def"], path, "median", 2, 2),
    mk-functional("median-functional", [list: "median-def"], path, "functionality.arr", "median: functionality", 4, some("median")),
    mk-wheat("median-wheat-1", [list: "median-diversity"], path, "median/wheat-1.arr", "median", 1),

    mk-wheat("median-wheat-2", [list: "median-diversity"], path, "median/wheat-2.arr", "median", 1),

    mk-chaff("median-chaff-1", [list: "median-diversity"], path, "median/chaff-1.arr", "median", 1),
    mk-chaff("median-chaff-2", [list: "median-diversity"], path, "median/chaff-2.arr", "median", 1),
    mk-chaff("median-chaff-3", [list: "median-diversity"], path, "median/chaff-3.arr", "median", 1),
    mk-chaff("median-chaff-4", [list: "median-diversity"], path, "median/chaff-4.arr", "median", 1),
    mk-chaff("median-chaff-5", [list: "median-diversity"], path, "median/chaff-5.arr", "median", 1),
    ]
end

spec = build-graders("submission/assignment.arr")
