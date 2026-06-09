use context autograder-spec
provide: spec end

include graders

fun build-graders(path :: String):
  [list:
    mk-well-formed("wf", empty, path),

    mk-wheat("wheat-1-fact", [list: "wf"], path, "fact/wheat-1.arr", "fact", 1),
    # wheat-2 uses a nested subroutine (fact-iter) -- exercises allow-subr-in-whaff
    mk-wheat("wheat-2-fact", [list: "wf"], path, "fact/wheat-2.arr", "fact", 1),

    mk-chaff("chaff-adds-1",   [list: "wf"], path, "fact/chaff-1.arr", "fact", 1),
    mk-chaff("chaff-doubles",  [list: "wf"], path, "fact/chaff-2.arr", "fact", 1),
    mk-chaff("chaff-1-1-2",    [list: "wf"], path, "fact/chaff-3.arr", "fact", 1),
    mk-chaff("chaff-identity", [list: "wf"], path, "fact/chaff-4.arr", "fact", 1),
  ]
end

spec = build-graders("submission/assignment.arr")
