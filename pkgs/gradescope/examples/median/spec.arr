use context autograder-spec
provide: spec end

include graders

fun build-graders(path :: String):
  [list:
    mk-well-formed("wf", empty, path),

    mk-wheat("wheat-1-median", [list: "wf"], path, "median/median-wheat.arr",   "median", 1),
    mk-wheat("wheat-2-median", [list: "wf"], path, "median/median-wheat-2.arr", "median", 1),

    mk-chaff("chaff-lower-on-even", [list: "wf"], path, "median/median-chaff-lower-on-even.arr", "median", 1),
    mk-chaff("chaff-upper-on-even", [list: "wf"], path, "median/median-chaff-upper-on-even.arr", "median", 1),
    mk-chaff("chaff-mean",          [list: "wf"], path, "median/median-chaff-mean.arr",          "median", 1),
    mk-chaff("chaff-mode",          [list: "wf"], path, "median/median-chaff-mode.arr",          "median", 1),
    mk-chaff("chaff-no-sort",       [list: "wf"], path, "median/median-chaff-no-sort.arr",       "median", 1),
  ]
end

spec = build-graders("submission/assignment.arr")
