use context autograder-spec
provide: spec end

include graders

fun build-graders(path :: String):
  [list:

    mk-wheat("join-lists-wheat-1a", empty, path, "join-lists/join-lists-wheat.arr", "j-first", 1),
    mk-wheat("join-lists-wheat-1b", empty, path, "join-lists/join-lists-wheat.arr", "j-rest", 1),
    mk-wheat("join-lists-wheat-1c", empty, path, "join-lists/join-lists-wheat.arr", "j-length", 1),
    mk-wheat("join-lists-wheat-1d", empty, path, "join-lists/join-lists-wheat.arr", "j-nth", 1),
    mk-wheat("join-lists-wheat-1e", empty, path, "join-lists/join-lists-wheat.arr", "j-max", 1),
    mk-wheat("join-lists-wheat-1f", empty, path, "join-lists/join-lists-wheat.arr", "j-map", 1),
    mk-wheat("join-lists-wheat-1g", empty, path, "join-lists/join-lists-wheat.arr", "j-filter", 1),
    mk-wheat("join-lists-wheat-1h", empty, path, "join-lists/join-lists-wheat.arr", "j-reduce", 1),
    mk-wheat("join-lists-wheat-1i", empty, path, "join-lists/join-lists-wheat.arr", "j-sort", 1),

    mk-wheat("join-lists-wheat-2a", empty, path, "join-lists/join-lists-wheat-2.arr", "j-first", 1),
    mk-wheat("join-lists-wheat-2b", empty, path, "join-lists/join-lists-wheat-2.arr", "j-rest", 1),
    mk-wheat("join-lists-wheat-2c", empty, path, "join-lists/join-lists-wheat-2.arr", "j-length", 1),
    mk-wheat("join-lists-wheat-2d", empty, path, "join-lists/join-lists-wheat-2.arr", "j-nth", 1),
    mk-wheat("join-lists-wheat-2e", empty, path, "join-lists/join-lists-wheat-2.arr", "j-max", 1),
    mk-wheat("join-lists-wheat-2f", empty, path, "join-lists/join-lists-wheat-2.arr", "j-map", 1),
    mk-wheat("join-lists-wheat-2g", empty, path, "join-lists/join-lists-wheat-2.arr", "j-filter", 1),
    mk-wheat("join-lists-wheat-2h", empty, path, "join-lists/join-lists-wheat-2.arr", "j-reduce", 1),
    mk-wheat("join-lists-wheat-2i", empty, path, "join-lists/join-lists-wheat-2.arr", "j-sort", 1),

    mk-chaff("join-lists-chaff-1", empty, path, "join-lists/join-lists-chaff-jfilter-error-on-all-removed.arr", "j-filter", 1),
    mk-chaff("join-lists-chaff-2", empty, path, "join-lists/join-lists-chaff-jfilter-error-on-none-removed.arr", "j-filter", 1),
    mk-chaff("join-lists-chaff-3", empty, path, "join-lists/join-lists-chaff-jfirst-fails-on-one.arr", "j-first", 1),
    mk-chaff("join-lists-chaff-4", empty, path, "join-lists/join-lists-chaff-jmap-error-on-empty.arr", "j-map", 1),
    mk-chaff("join-lists-chaff-5", empty, path, "join-lists/join-lists-chaff-jmax-only-alphanumeric.arr", "j-max", 1),
    mk-chaff("join-lists-chaff-6", empty, path, "join-lists/join-lists-chaff-jnth-one-indexed.arr", "j-nth", 1),
    mk-chaff("join-lists-chaff-7", empty, path, "join-lists/join-lists-chaff-jreduce-opposite-order.arr", "j-reduce", 1),
    mk-chaff("join-lists-chaff-8", empty, path, "join-lists/join-lists-chaff-jsort-fails-on-different-elts-equal-by-cmp.arr", "j-sort", 1),
    mk-chaff("join-lists-chaff-9", empty, path, "join-lists/join-lists-chaff-jsort-only-alphanumeric.arr", "j-sort", 1),

    ]
end

spec = build-graders("submission/assignment.arr")
