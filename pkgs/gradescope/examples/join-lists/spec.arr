use context autograder-spec
provide: spec end

include graders

fun build-graders(path :: String):
  [list:
    mk-well-formed("wf", empty, path),

    mk-wheat("wheat-1-j-first", [list: "wf"], path, "join-lists/join-lists-wheat.arr", "j-first", 1),
    mk-wheat("wheat-1-j-rest", [list: "wf"], path, "join-lists/join-lists-wheat.arr", "j-rest", 1),
    mk-wheat("wheat-1-j-length", [list: "wf"], path, "join-lists/join-lists-wheat.arr", "j-length", 1),
    mk-wheat("wheat-1-j-nth", [list: "wf"], path, "join-lists/join-lists-wheat.arr", "j-nth", 1),
    mk-wheat("wheat-1-j-max", [list: "wf"], path, "join-lists/join-lists-wheat.arr", "j-max", 1),
    mk-wheat("wheat-1-j-map", [list: "wf"], path, "join-lists/join-lists-wheat.arr", "j-map", 1),
    mk-wheat("wheat-1-j-filter", [list: "wf"], path, "join-lists/join-lists-wheat.arr", "j-filter", 1),
    mk-wheat("wheat-1-j-reduce", [list: "wf"], path, "join-lists/join-lists-wheat.arr", "j-reduce", 1),
    mk-wheat("wheat-1-j-sort", [list: "wf"], path, "join-lists/join-lists-wheat.arr", "j-sort", 1),

    mk-wheat("wheat-2-j-first", [list: "wf"], path, "join-lists/join-lists-wheat-2.arr", "j-first", 1),
    mk-wheat("wheat-2-j-rest", [list: "wf"], path, "join-lists/join-lists-wheat-2.arr", "j-rest", 1),
    mk-wheat("wheat-2-j-length", [list: "wf"], path, "join-lists/join-lists-wheat-2.arr", "j-length", 1),
    mk-wheat("wheat-2-j-nth", [list: "wf"], path, "join-lists/join-lists-wheat-2.arr", "j-nth", 1),
    mk-wheat("wheat-2-j-max", [list: "wf"], path, "join-lists/join-lists-wheat-2.arr", "j-max", 1),
    mk-wheat("wheat-2-j-map", [list: "wf"], path, "join-lists/join-lists-wheat-2.arr", "j-map", 1),
    mk-wheat("wheat-2-j-filter", [list: "wf"], path, "join-lists/join-lists-wheat-2.arr", "j-filter", 1),
    mk-wheat("wheat-2-j-reduce", [list: "wf"], path, "join-lists/join-lists-wheat-2.arr", "j-reduce", 1),
    mk-wheat("wheat-2-j-sort", [list: "wf"], path, "join-lists/join-lists-wheat-2.arr", "j-sort", 1),

    mk-chaff("chaff-jfilter-error-on-all-removed", [list: "wf"], path, "join-lists/join-lists-chaff-jfilter-error-on-all-removed.arr", "j-filter", 1),
    mk-chaff("chaff-jfilter-error-on-none-removed", [list: "wf"], path, "join-lists/join-lists-chaff-jfilter-error-on-none-removed.arr", "j-filter", 1),
    mk-chaff("chaff-jfirst-fails-on-one", [list: "wf"], path, "join-lists/join-lists-chaff-jfirst-fails-on-one.arr", "j-first", 1),
    mk-chaff("chaff-jmap-error-on-empty", [list: "wf"], path, "join-lists/join-lists-chaff-jmap-error-on-empty.arr", "j-map", 1),
    mk-chaff("chaff-jmax-only-alphanumeric", [list: "wf"], path, "join-lists/join-lists-chaff-jmax-only-alphanumeric.arr", "j-max", 1),
    mk-chaff("chaff-jnth-one-indexed", [list: "wf"], path, "join-lists/join-lists-chaff-jnth-one-indexed.arr", "j-nth", 1),
    mk-chaff("chaff-jreduce-opposite-order", [list: "wf"], path, "join-lists/join-lists-chaff-jreduce-opposite-order.arr", "j-reduce", 1),
    mk-chaff("chaff-jsort-fails-on-different-elts-equal-by-cmp", [list: "wf"], path, "join-lists/join-lists-chaff-jsort-fails-on-different-elts-equal-by-cmp.arr", "j-sort", 1),
    mk-chaff("chaff-jsort-only-alphanumeric", [list: "wf"], path, "join-lists/join-lists-chaff-jsort-only-alphanumeric.arr", "j-sort", 1),
  ]
end

spec = build-graders("submission/assignment.arr")
