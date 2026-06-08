use context autograder-spec
provide: spec end

include graders

fun build-graders(path :: String):
  [list:
    mk-well-formed("wf", empty, path),

    mk-wheat("wheat-1-recommend",     [list: "wf"], path, "nile/nile-wheat.arr",   "recommend",     1),
    mk-wheat("wheat-1-popular-pairs", [list: "wf"], path, "nile/nile-wheat.arr",   "popular-pairs", 1),
    mk-wheat("wheat-2-recommend",     [list: "wf"], path, "nile/nile-wheat-2.arr", "recommend",     1),
    mk-wheat("wheat-2-popular-pairs", [list: "wf"], path, "nile/nile-wheat-2.arr", "popular-pairs", 1),

    mk-chaff("chaff-io-case-insensitive", [list: "wf"], path, "nile/nile-chaff-io-case-insensitive.arr", "recommend", 1),
    mk-chaff("chaff-popular-pairs-length-not-freq", [list: "wf"], path, "nile/nile-chaff-popular-pairs-length-not-freq.arr", "popular-pairs", 1),
    mk-chaff("chaff-popular-pairs-no-multiple-recs-returns-empty", [list: "wf"], path, "nile/nile-chaff-popular-pairs-no-multiple-recs-returns-empty.arr", "popular-pairs", 1),
    mk-chaff("chaff-recommend-length-instead-of-freq", [list: "wf"], path, "nile/nile-chaff-recommend-length-instead-of-freq.arr", "recommend", 1),
    mk-chaff("chaff-recommend-no-multiple-recs-chooses-first-preserve-freq", [list: "wf"], path, "nile/nile-chaff-recommend-no-multiple-recs-chooses-first-preserve-freq.arr", "recommend", 1),
    mk-chaff("chaff-recommend-requires-multiple-files", [list: "wf"], path, "nile/nile-chaff-recommend-requires-multiple-files.arr", "recommend", 1),
  ]
end

spec = build-graders("submission/assignment.arr")
