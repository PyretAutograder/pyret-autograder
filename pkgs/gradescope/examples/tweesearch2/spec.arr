use context autograder-spec
provide: spec end

include graders

fun build-graders(path :: String):
  [list:

    mk-wheat("tweesearch2-wheat-1", empty, path, "tweesearch2/tweesearch2-wheat.arr", "search", 1),

    mk-wheat("tweesearch2-wheat-2", empty, path, "tweesearch2/tweesearch2-wheat-2.arr", "search", 1),

    mk-chaff("tweesearch2-chaff-1", empty, path, "tweesearch2/tweesearch2-chaff-case-sensitive.arr", "search", 1),
    mk-chaff("tweesearch2-chaff-2", empty, path, "tweesearch2/tweesearch2-chaff-doesnt-remove-punctuation.arr", "search", 1),
    mk-chaff("tweesearch2-chaff-3", empty, path, "tweesearch2/tweesearch2-chaff-doesnt-sort-output.arr", "search", 1),
    mk-chaff("tweesearch2-chaff-4", empty, path, "tweesearch2/tweesearch2-chaff-fail-when-ancestor-in-list.arr", "search", 1),
    mk-chaff("tweesearch2-chaff-5", empty, path, "tweesearch2/tweesearch2-chaff-fails-on-no-tweets.arr", "search", 1),
    mk-chaff("tweesearch2-chaff-6", empty, path, "tweesearch2/tweesearch2-chaff-fails-on-tie.arr", "search", 1),
    mk-chaff("tweesearch2-chaff-7", empty, path, "tweesearch2/tweesearch2-chaff-ignores-threshold.arr", "search", 1),
    mk-chaff("tweesearch2-chaff-8", empty, path, "tweesearch2/tweesearch2-chaff-leaves-duplicates.arr", "search", 1),
    mk-chaff("tweesearch2-chaff-9", empty, path, "tweesearch2/tweesearch2-chaff-no-sort.arr", "search", 1),
    mk-chaff("tweesearch2-chaff-10", empty, path, "tweesearch2/tweesearch2-chaff-removes-duplicates-by-equal-always.arr", "search", 1),
    mk-chaff("tweesearch2-chaff-11", empty, path, "tweesearch2/tweesearch2-chaff-removes-extra-spaces.arr", "search", 1),
    mk-chaff("tweesearch2-chaff-12", empty, path, "tweesearch2/tweesearch2-chaff-threshold-exclusive.arr", "search", 1),

    ]
end

spec = build-graders("submission/assignment.arr")
