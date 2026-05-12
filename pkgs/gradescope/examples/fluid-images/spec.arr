use context autograder-spec
provide: spec end

include graders

fun build-graders(path :: String):
  [list:

    mk-wheat("fluid-images-wheat-1a", empty, path, "fluid-images/fluid-images-wheat.arr", "liquify-memoization", 1),
    mk-wheat("fluid-images-wheat-1b", empty, path, "fluid-images/fluid-images-wheat.arr", "liquify-dynamic-programming", 1),

    mk-wheat("fluid-images-wheat-2a", empty, path, "fluid-images/fluid-images-wheat-2.arr", "liquify-memoization", 1),
    mk-wheat("fluid-images-wheat-2b", empty, path, "fluid-images/fluid-images-wheat-2.arr", "liquify-dynamic-programming", 1),

    mk-chaff("fluid-images-chaff-1", empty, path, "fluid-images/fluid-images-chaff-border-brightness-ten-dynprog.arr", "liquify-dynamic-programming", 1),
    mk-chaff("fluid-images-chaff-2", empty, path, "fluid-images/fluid-images-chaff-down-right-only-dynprog.arr", "liquify-dynamic-programming", 1),
    mk-chaff("fluid-images-chaff-3", empty, path, "fluid-images/fluid-images-chaff-fail-on-multiple-seams-dynprog.arr", "liquify-dynamic-programming", 1),
    mk-chaff("fluid-images-chaff-4", empty, path, "fluid-images/fluid-images-chaff-fail-on-zero-memo.arr", "liquify-memoization", 1),
    mk-chaff("fluid-images-chaff-5", empty, path, "fluid-images/fluid-images-chaff-fails-on-tall-memo.arr", "liquify-memoization", 1),
    mk-chaff("fluid-images-chaff-6", empty, path, "fluid-images/fluid-images-chaff-prefers-right-memo.arr", "liquify-memoization", 1),
    mk-chaff("fluid-images-chaff-7", empty, path, "fluid-images/fluid-images-chaff-down-left-only-dynprog.arr", "liquify-dynamic-programming", 1),
    mk-chaff("fluid-images-chaff-8", empty, path, "fluid-images/fluid-images-chaff-down-left-only-memo.arr", "liquify-memoization", 1),
    mk-chaff("fluid-images-chaff-9", empty, path, "fluid-images/fluid-images-chaff-down-right-only-memo.arr", "liquify-memoization", 1),

    ]
end

spec = build-graders("submission/assignment.arr")
