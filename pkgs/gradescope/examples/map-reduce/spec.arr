use context autograder-spec
provide: spec end

include graders

fun build-graders(path :: String):
  [list:
    mk-well-formed("wf", empty, path),

    mk-wheat("wheat-1-map-reduce",     [list: "wf"], path, "map-reduce/map-reduce-wheat.arr",   "map-reduce",     1),
    mk-wheat("wheat-1-anagram-map",    [list: "wf"], path, "map-reduce/map-reduce-wheat.arr",   "anagram-map",    1),
    mk-wheat("wheat-1-anagram-reduce", [list: "wf"], path, "map-reduce/map-reduce-wheat.arr",   "anagram-reduce", 1),
    mk-wheat("wheat-1-recommend",      [list: "wf"], path, "map-reduce/map-reduce-wheat.arr",   "recommend",      1),
    mk-wheat("wheat-1-popular-pairs",  [list: "wf"], path, "map-reduce/map-reduce-wheat.arr",   "popular-pairs",  1),

    mk-wheat("wheat-2-map-reduce",     [list: "wf"], path, "map-reduce/map-reduce-wheat-2.arr", "map-reduce",     1),
    mk-wheat("wheat-2-anagram-map",    [list: "wf"], path, "map-reduce/map-reduce-wheat-2.arr", "anagram-map",    1),
    mk-wheat("wheat-2-anagram-reduce", [list: "wf"], path, "map-reduce/map-reduce-wheat-2.arr", "anagram-reduce", 1),
    mk-wheat("wheat-2-recommend",      [list: "wf"], path, "map-reduce/map-reduce-wheat-2.arr", "recommend",      1),
    mk-wheat("wheat-2-popular-pairs",  [list: "wf"], path, "map-reduce/map-reduce-wheat-2.arr", "popular-pairs",  1),

    mk-chaff("chaff-each-file-separate", [list: "wf"], path, "map-reduce/map-reduce-chaff-each-file-separate.arr", "map-reduce", 1),
    mk-chaff("chaff-each-tag-unique",    [list: "wf"], path, "map-reduce/map-reduce-chaff-each-tag-unique.arr",    "anagram-map", 1),
    mk-chaff("chaff-case-insensitive",   [list: "wf"], path, "map-reduce/map-reduce-chaff-case-insensitive.arr",   "anagram-map", 1),
    mk-chaff("chaff-with-duplicates",    [list: "wf"], path, "map-reduce/map-reduce-chaff-with-duplicates.arr",    "anagram-reduce", 1),
    mk-chaff("chaff-nile-adds-all-books", [list: "wf"], path, "map-reduce/map-reduce-chaff-nile-adds-all-books.arr", "recommend", 1),
    mk-chaff("chaff-nile-recommend-only-returns-one-book", [list: "wf"], path, "map-reduce/map-reduce-chaff-nile-recommend-only-returns-one-book.arr", "recommend", 1),
    mk-chaff("chaff-nile-duplicate-pairs", [list: "wf"], path, "map-reduce/map-reduce-chaff-nile-duplicate-pairs.arr", "popular-pairs", 1),
    mk-chaff("chaff-nile-popular-pairs-only-returns-one-book", [list: "wf"], path, "map-reduce/map-reduce-chaff-nile-popular-pairs-only-returns-one-book.arr", "popular-pairs", 1),
  ]
end

spec = build-graders("submission/assignment.arr")
