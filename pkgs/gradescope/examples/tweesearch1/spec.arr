use context autograder-spec
provide: spec end

include graders

fun build-graders(path :: String):
  [list:

    mk-wheat("tweesearch1-wheat-1", empty, path, "tweesearch1/tweesearch1-wheat.arr", "search", 1),

    mk-wheat("tweesearch1-wheat-2", empty, path, "tweesearch1/tweesearch1-wheat-2.arr", "search", 1),

    mk-chaff("tweesearch1-chaff-1", empty, path, "tweesearch1/tweesearch1-chaff-case-sensitive.arr", "search", 1),
    mk-chaff("tweesearch1-chaff-2", empty, path, "tweesearch1/tweesearch1-chaff-doesnt-remove-punctuation.arr", "search", 1),
    mk-chaff("tweesearch1-chaff-3", empty, path, "tweesearch1/tweesearch1-chaff-doesnt-remove-unicode.arr", "search", 1),
    mk-chaff("tweesearch1-chaff-4", empty, path, "tweesearch1/tweesearch1-chaff-doesnt-sort-output.arr", "search", 1),
    mk-chaff("tweesearch1-chaff-5", empty, path, "tweesearch1/tweesearch1-chaff-fails-on-no-tweets.arr", "search", 1),
    mk-chaff("tweesearch1-chaff-6", empty, path, "tweesearch1/tweesearch1-chaff-fails-on-tie.arr", "search", 1),
    mk-chaff("tweesearch1-chaff-7", empty, path, "tweesearch1/tweesearch1-chaff-ignores-threshold.arr", "search", 1),
    mk-chaff("tweesearch1-chaff-8", empty, path, "tweesearch1/tweesearch1-chaff-removes-extra-spaces.arr", "search", 1),
    mk-chaff("tweesearch1-chaff-9", empty, path, "tweesearch1/tweesearch1-chaff-removes-numbers.arr", "search", 1),
    mk-chaff("tweesearch1-chaff-10", empty, path, "tweesearch1/tweesearch1-chaff-threshold-exclusive.arr", "search", 1),

    ]
end

spec = build-graders("submission/assignment.arr")
