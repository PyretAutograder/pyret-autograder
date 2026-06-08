use context autograder-spec
provide: spec end

include graders

fun build-graders(path :: String):
  [list:
    mk-well-formed("wf", empty, path),

    mk-wheat("wheat-1", [list: "wf"], path, "tweesearch3/tweesearch3-wheat.arr",   "search", 1),
    mk-wheat("wheat-2", [list: "wf"], path, "tweesearch3/tweesearch3-wheat-2.arr", "search", 1),

    mk-chaff("chaff-case-sensitive", [list: "wf"], path, "tweesearch3/tweesearch3-chaff-case-sensitive.arr", "search", 1),
    mk-chaff("chaff-does-not-recur-on-children", [list: "wf"], path, "tweesearch3/tweesearch3-chaff-does-not-recur-on-children.arr", "search", 1),
    mk-chaff("chaff-doesnt-count-self-in-subtree-size", [list: "wf"], path, "tweesearch3/tweesearch3-chaff-doesnt-count-self-in-subtree-size.arr", "search", 1),
    mk-chaff("chaff-doesnt-keep-grandchildren", [list: "wf"], path, "tweesearch3/tweesearch3-chaff-doesnt-keep-grandchildren.arr", "search", 1),
    mk-chaff("chaff-doesnt-remove-punctuation", [list: "wf"], path, "tweesearch3/tweesearch3-chaff-doesnt-remove-punctuation.arr", "search", 1),
    mk-chaff("chaff-doesnt-sort-output", [list: "wf"], path, "tweesearch3/tweesearch3-chaff-doesnt-sort-output.arr", "search", 1),
    mk-chaff("chaff-doesnt-use-subtree-size", [list: "wf"], path, "tweesearch3/tweesearch3-chaff-doesnt-use-subtree-size.arr", "search", 1),
    mk-chaff("chaff-double-counts-self-in-subtree-size", [list: "wf"], path, "tweesearch3/tweesearch3-chaff-double-counts-self-in-subtree-size.arr", "search", 1),
    mk-chaff("chaff-fails-on-no-tweets", [list: "wf"], path, "tweesearch3/tweesearch3-chaff-fails-on-no-tweets.arr", "search", 1),
    mk-chaff("chaff-fails-on-tie", [list: "wf"], path, "tweesearch3/tweesearch3-chaff-fails-on-tie.arr", "search", 1),
    mk-chaff("chaff-ignores-parent-relevance", [list: "wf"], path, "tweesearch3/tweesearch3-chaff-ignores-parent-relevance.arr", "search", 1),
    mk-chaff("chaff-ignores-threshold", [list: "wf"], path, "tweesearch3/tweesearch3-chaff-ignores-threshold.arr", "search", 1),
    mk-chaff("chaff-no-sort", [list: "wf"], path, "tweesearch3/tweesearch3-chaff-no-sort.arr", "search", 1),
    mk-chaff("chaff-only-checks-first-child", [list: "wf"], path, "tweesearch3/tweesearch3-chaff-only-checks-first-child.arr", "search", 1),
    mk-chaff("chaff-only-keeps-lowercase-chars", [list: "wf"], path, "tweesearch3/tweesearch3-chaff-only-keeps-lowercase-chars.arr", "search", 1),
    mk-chaff("chaff-removes-extra-spaces", [list: "wf"], path, "tweesearch3/tweesearch3-chaff-removes-extra-spaces.arr", "search", 1),
    mk-chaff("chaff-threshold-exclusive", [list: "wf"], path, "tweesearch3/tweesearch3-chaff-threshold-exclusive.arr", "search", 1),
    mk-chaff("chaff-uses-parent-overlap-not-relevance", [list: "wf"], path, "tweesearch3/tweesearch3-chaff-uses-parent-overlap-not-relevance.arr", "search", 1),
    mk-chaff("chaff-uses-root-relevance-for-all-parents", [list: "wf"], path, "tweesearch3/tweesearch3-chaff-uses-root-relevance-for-all-parents.arr", "search", 1),
  ]
end

spec = build-graders("submission/assignment.arr")
