use context autograder-spec
provide: spec end

include graders

fun build-graders(path :: String):
  [list:

    mk-wheat("tweesearch3-wheat-1", empty, path, "tweesearch3/tweesearch3-wheat.arr", "search", 1),

    mk-wheat("tweesearch3-wheat-2", empty, path, "tweesearch3/tweesearch3-wheat-2.arr", "search", 1),

    mk-chaff("tweesearch3-chaff-1", empty, path, "tweesearch3/tweesearch3-chaff-case-sensitive.arr", "search", 1),
    mk-chaff("tweesearch3-chaff-2", empty, path, "tweesearch3/tweesearch3-chaff-does-not-recur-on-children.arr", "search", 1),
    mk-chaff("tweesearch3-chaff-3", empty, path, "tweesearch3/tweesearch3-chaff-doesnt-count-self-in-subtree-size.arr", "search", 1),
    mk-chaff("tweesearch3-chaff-4", empty, path, "tweesearch3/tweesearch3-chaff-doesnt-keep-grandchildren.arr", "search", 1),
    mk-chaff("tweesearch3-chaff-5", empty, path, "tweesearch3/tweesearch3-chaff-doesnt-remove-punctuation.arr", "search", 1),
    mk-chaff("tweesearch3-chaff-6", empty, path, "tweesearch3/tweesearch3-chaff-doesnt-sort-output.arr", "search", 1),
    mk-chaff("tweesearch3-chaff-7", empty, path, "tweesearch3/tweesearch3-chaff-doesnt-use-subtree-size.arr", "search", 1),
    mk-chaff("tweesearch3-chaff-8", empty, path, "tweesearch3/tweesearch3-chaff-double-counts-self-in-subtree-size.arr", "search", 1),
    mk-chaff("tweesearch3-chaff-9", empty, path, "tweesearch3/tweesearch3-chaff-fails-on-no-tweets.arr", "search", 1),
    mk-chaff("tweesearch3-chaff-10", empty, path, "tweesearch3/tweesearch3-chaff-fails-on-tie.arr", "search", 1),
    mk-chaff("tweesearch3-chaff-11", empty, path, "tweesearch3/tweesearch3-chaff-ignores-parent-relevance.arr", "search", 1),
    mk-chaff("tweesearch3-chaff-12", empty, path, "tweesearch3/tweesearch3-chaff-ignores-threshold.arr", "search", 1),
    mk-chaff("tweesearch3-chaff-13", empty, path, "tweesearch3/tweesearch3-chaff-no-sort.arr", "search", 1),
    mk-chaff("tweesearch3-chaff-14", empty, path, "tweesearch3/tweesearch3-chaff-only-checks-first-child.arr", "search", 1),
    mk-chaff("tweesearch3-chaff-15", empty, path, "tweesearch3/tweesearch3-chaff-only-keeps-lowercase-chars.arr", "search", 1),
    mk-chaff("tweesearch3-chaff-16", empty, path, "tweesearch3/tweesearch3-chaff-removes-extra-spaces.arr", "search", 1),
    mk-chaff("tweesearch3-chaff-17", empty, path, "tweesearch3/tweesearch3-chaff-threshold-exclusive.arr", "search", 1),
    mk-chaff("tweesearch3-chaff-18", empty, path, "tweesearch3/tweesearch3-chaff-uses-parent-overlap-not-relevance.arr", "search", 1),
    mk-chaff("tweesearch3-chaff-19", empty, path, "tweesearch3/tweesearch3-chaff-uses-root-relevance-for-all-parents.arr", "search", 1),

    ]
end

spec = build-graders("submission/assignment.arr")
