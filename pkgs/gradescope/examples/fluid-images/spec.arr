use context autograder-spec
provide: spec end

include graders

fun build-graders(path :: String):
  [list:
    mk-well-formed("wf", empty, path),

    # Wheats — student tests must pass against two correct implementations
    mk-wheat("wheat-1-memo",  [list: "wf"], path, "fluid-images/fluid-images-wheat.arr",   "liquify-memoization",         1),
    mk-wheat("wheat-1-dp",    [list: "wf"], path, "fluid-images/fluid-images-wheat.arr",   "liquify-dynamic-programming", 1),
    mk-wheat("wheat-2-memo",  [list: "wf"], path, "fluid-images/fluid-images-wheat-2.arr", "liquify-memoization",         1),
    mk-wheat("wheat-2-dp",    [list: "wf"], path, "fluid-images/fluid-images-wheat-2.arr", "liquify-dynamic-programming", 1),

    # Chaffs — student tests must catch each subtly broken implementation
    mk-chaff("chaff-border-brightness-dp", [list: "wf"], path, "fluid-images/fluid-images-chaff-border-brightness-ten-dynprog.arr", "liquify-dynamic-programming", 1),
    mk-chaff("chaff-down-right-dp",        [list: "wf"], path, "fluid-images/fluid-images-chaff-down-right-only-dynprog.arr",       "liquify-dynamic-programming", 1),
    mk-chaff("chaff-multiple-seams-dp",    [list: "wf"], path, "fluid-images/fluid-images-chaff-fail-on-multiple-seams-dynprog.arr", "liquify-dynamic-programming", 1),
    mk-chaff("chaff-down-left-dp",         [list: "wf"], path, "fluid-images/fluid-images-chaff-down-left-only-dynprog.arr",        "liquify-dynamic-programming", 1),
    mk-chaff("chaff-fail-on-zero-memo",    [list: "wf"], path, "fluid-images/fluid-images-chaff-fail-on-zero-memo.arr",            "liquify-memoization", 1),
    mk-chaff("chaff-fails-on-tall-memo",   [list: "wf"], path, "fluid-images/fluid-images-chaff-fails-on-tall-memo.arr",           "liquify-memoization", 1),
    mk-chaff("chaff-prefers-right-memo",   [list: "wf"], path, "fluid-images/fluid-images-chaff-prefers-right-memo.arr",           "liquify-memoization", 1),
    mk-chaff("chaff-down-left-memo",       [list: "wf"], path, "fluid-images/fluid-images-chaff-down-left-only-memo.arr",          "liquify-memoization", 1),
    mk-chaff("chaff-down-right-memo",      [list: "wf"], path, "fluid-images/fluid-images-chaff-down-right-only-memo.arr",         "liquify-memoization", 1),
  ]
end

spec = build-graders("submission/assignment.arr")
