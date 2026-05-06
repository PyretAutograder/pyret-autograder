use context autograder-spec
provide: spec end

include graders

fun build-graders(path :: String):
  [list:
    mk-well-formed("wf", empty, path),
    mk-training-wheels("tw", [list: "wf"], path, false),
    mk-fn-def("fact-def", [list: "tw"], path, "fact", 1),
    mk-self-test("fact-self-test", [list: "fact-def"], path, "fact", 1),
    mk-test-diversity("fact-diversity", [list: "fact-def"], path, "fact", 2, 2),
    mk-functional("fact-functional", [list: "fact-def"], path, "functionality.arr", "fact: functionality", 4, some("fact")),
    mk-wheat("fact-wheat-1", [list: "fact-diversity"], path, "fact/wheat-1.arr", "fact", 1),

    # NOTE: wheat-2 fails because it uses a subroutine!
    mk-wheat("fact-wheat-2", [list: "fact-diversity"], path, "fact/wheat-2.arr", "fact", 1),

    mk-chaff("fact-chaff-1", [list: "fact-diversity"], path, "fact/chaff-1.arr", "fact", 1),
    mk-chaff("fact-chaff-2", [list: "fact-diversity"], path, "fact/chaff-2.arr", "fact", 1),
    mk-chaff("fact-chaff-3", [list: "fact-diversity"], path, "fact/chaff-3.arr", "fact", 1),
    mk-chaff("fact-chaff-4", [list: "fact-diversity"], path, "fact/chaff-4.arr", "fact", 1),
    ]
end

spec = build-graders("submission/assignment.arr")
