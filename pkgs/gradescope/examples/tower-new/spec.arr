use context autograder-spec
provide: spec end

include graders

fun build-graders(path :: String):
  [list:
    mk-well-formed("wf", empty, path),

    mk-wheat("wheat-1-num-rooms", [list: "wf"], path, "num-rooms/wheat-1.arr", "num-rooms", 1),
    mk-wheat("wheat-2-num-rooms", [list: "wf"], path, "num-rooms/wheat-2.arr", "num-rooms", 1),
    mk-chaff("chaff-1-num-rooms", [list: "wf"], path, "num-rooms/chaff-1.arr", "num-rooms", 1),
    mk-chaff("chaff-2-num-rooms", [list: "wf"], path, "num-rooms/chaff-2.arr", "num-rooms", 1),
    mk-chaff("chaff-3-num-rooms", [list: "wf"], path, "num-rooms/chaff-3.arr", "num-rooms", 1),

    mk-wheat("wheat-1-max-rooms", [list: "wf"], path, "max-rooms/wheat-1.arr", "max-rooms", 1),
    mk-wheat("wheat-2-max-rooms", [list: "wf"], path, "max-rooms/wheat-2.arr", "max-rooms", 1),
    mk-chaff("chaff-1-max-rooms", [list: "wf"], path, "max-rooms/chaff-1.arr", "max-rooms", 1),
    mk-chaff("chaff-2-max-rooms", [list: "wf"], path, "max-rooms/chaff-2.arr", "max-rooms", 1),
    mk-chaff("chaff-3-max-rooms", [list: "wf"], path, "max-rooms/chaff-3.arr", "max-rooms", 1),

    mk-wheat("wheat-1-first-floor", [list: "wf"], path, "first-floor/wheat-1.arr", "first-floor", 1),
    mk-wheat("wheat-2-first-floor", [list: "wf"], path, "first-floor/wheat-2.arr", "first-floor", 1),
    mk-chaff("chaff-1-first-floor", [list: "wf"], path, "first-floor/chaff-1.arr", "first-floor", 1),
    mk-chaff("chaff-2-first-floor", [list: "wf"], path, "first-floor/chaff-2.arr", "first-floor", 1),
    mk-chaff("chaff-3-first-floor", [list: "wf"], path, "first-floor/chaff-3.arr", "first-floor", 1),
    mk-chaff("chaff-4-first-floor", [list: "wf"], path, "first-floor/chaff-4.arr", "first-floor", 1),

    mk-wheat("wheat-1-is-unbalanced", [list: "wf"], path, "is-unbalanced/wheat-1.arr", "is-unbalanced", 1),
    mk-wheat("wheat-2-is-unbalanced", [list: "wf"], path, "is-unbalanced/wheat-2.arr", "is-unbalanced", 1),
    mk-chaff("chaff-1-is-unbalanced", [list: "wf"], path, "is-unbalanced/chaff-1.arr", "is-unbalanced", 1),
    mk-chaff("chaff-2-is-unbalanced", [list: "wf"], path, "is-unbalanced/chaff-2.arr", "is-unbalanced", 1),
    mk-chaff("chaff-3-is-unbalanced", [list: "wf"], path, "is-unbalanced/chaff-3.arr", "is-unbalanced", 1),
    mk-chaff("chaff-4-is-unbalanced", [list: "wf"], path, "is-unbalanced/chaff-4.arr", "is-unbalanced", 1),
  ]
end

spec = build-graders("submission/assignment.arr")
