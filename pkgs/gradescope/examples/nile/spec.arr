use context autograder-spec
provide: spec end

include graders

fun build-graders(path :: String):
  [list:
    mk-wheat("nile-wheat-1a", empty, path, "nile/nile-wheat.arr", "popular-pairs", 1),
    mk-wheat("nile-wheat-1b", empty, path, "nile/nile-wheat.arr", "recommend", 1),
    mk-wheat("nile-wheat-2a", empty, path, "nile/nile-wheat-2.arr", "popular-pairs", 1),
    mk-wheat("nile-wheat-2b", empty, path, "nile/nile-wheat-2.arr", "recommend", 1),

    # mk-chaff("nile-chaff-1", empty, path, "nile/nile-chaff-io-case-insensitive.arr", "nile", 1),
    mk-chaff("nile-chaff-2", empty, path, "nile/nile-chaff-popular-pairs-length-not-freq.arr", "popular-pairs", 1),
    mk-chaff("nile-chaff-3", empty, path, "nile/nile-chaff-popular-pairs-no-multiple-recs-returns-empty.arr", "popular-pairs", 1),
    mk-chaff("nile-chaff-4", empty, path, "nile/nile-chaff-recommend-length-instead-of-freq.arr", "recommend", 1),
    mk-chaff("nile-chaff-5", empty, path, "nile/nile-chaff-recommend-no-multiple-recs-chooses-first-preserve-freq.arr", "recommend", 1),
    mk-chaff("nile-chaff-6", empty, path, "nile/nile-chaff-recommend-requires-multiple-files.arr", "recommend", 1),
    ]
end

spec = build-graders("submission/assignment.arr")
