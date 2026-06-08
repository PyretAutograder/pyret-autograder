use context autograder-spec
provide: spec end

include graders

fun build-graders(path :: String):
  [list:
    mk-well-formed("wf", empty, path),

    # Wheats — student tests must pass against two correct implementations
    mk-wheat("wheat-1", [list: "wf"], path, "tweesearch2/tweesearch2-wheat.arr",   "search", 1),
    mk-wheat("wheat-2", [list: "wf"], path, "tweesearch2/tweesearch2-wheat-2.arr", "search", 1),

    # Chaffs — student tests must catch each subtly broken implementation
    mk-chaff("chaff-case-sensitive",         [list: "wf"], path, "tweesearch2/tweesearch2-chaff-case-sensitive.arr",                    "search", 1),
    mk-chaff("chaff-keeps-punctuation",      [list: "wf"], path, "tweesearch2/tweesearch2-chaff-doesnt-remove-punctuation.arr",         "search", 1),
    mk-chaff("chaff-doesnt-sort",            [list: "wf"], path, "tweesearch2/tweesearch2-chaff-doesnt-sort-output.arr",                "search", 1),
    mk-chaff("chaff-fail-ancestor-in-list",  [list: "wf"], path, "tweesearch2/tweesearch2-chaff-fail-when-ancestor-in-list.arr",        "search", 1),
    mk-chaff("chaff-fails-on-no-tweets",     [list: "wf"], path, "tweesearch2/tweesearch2-chaff-fails-on-no-tweets.arr",                "search", 1),
    mk-chaff("chaff-fails-on-tie",           [list: "wf"], path, "tweesearch2/tweesearch2-chaff-fails-on-tie.arr",                      "search", 1),
    mk-chaff("chaff-ignores-threshold",      [list: "wf"], path, "tweesearch2/tweesearch2-chaff-ignores-threshold.arr",                "search", 1),
    mk-chaff("chaff-leaves-duplicates",      [list: "wf"], path, "tweesearch2/tweesearch2-chaff-leaves-duplicates.arr",                "search", 1),
    mk-chaff("chaff-no-sort",                [list: "wf"], path, "tweesearch2/tweesearch2-chaff-no-sort.arr",                          "search", 1),
    mk-chaff("chaff-removes-dups-always",    [list: "wf"], path, "tweesearch2/tweesearch2-chaff-removes-duplicates-by-equal-always.arr", "search", 1),
    mk-chaff("chaff-removes-extra-spaces",   [list: "wf"], path, "tweesearch2/tweesearch2-chaff-removes-extra-spaces.arr",             "search", 1),
    mk-chaff("chaff-threshold-exclusive",    [list: "wf"], path, "tweesearch2/tweesearch2-chaff-threshold-exclusive.arr",              "search", 1),
    mk-chaff("chaff-no-parents-checked",     [list: "wf"], path, "tweesearch2/tweesearch2-no-parents-checked.arr",                     "search", 1),
  ]
end

spec = build-graders("submission/assignment.arr")
