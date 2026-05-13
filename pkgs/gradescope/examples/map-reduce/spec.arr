use context autograder-spec
provide: spec end

include graders

fun build-graders(path :: String):
  [list:

    mk-wheat("map-reduce-wheat-1a", empty, path, "map-reduce/map-reduce-wheat.arr", "map-reduce", 1),
    mk-wheat("map-reduce-wheat-1b", empty, path, "map-reduce/map-reduce-wheat.arr", "anagram-map", 1),
    mk-wheat("map-reduce-wheat-1c", empty, path, "map-reduce/map-reduce-wheat.arr", "anagram-reduce", 1),
    mk-wheat("map-reduce-wheat-1d", empty, path, "map-reduce/map-reduce-wheat.arr", "recommend", 1),
    mk-wheat("map-reduce-wheat-1e", empty, path, "map-reduce/map-reduce-wheat.arr", "popular-pairs", 1),

    mk-wheat("map-reduce-wheat-2a", empty, path, "map-reduce/map-reduce-wheat-2.arr", "map-reduce", 1),
    mk-wheat("map-reduce-wheat-2b", empty, path, "map-reduce/map-reduce-wheat-2.arr", "anagram-map", 1),
    mk-wheat("map-reduce-wheat-2c", empty, path, "map-reduce/map-reduce-wheat-2.arr", "anagram-reduce", 1),
    mk-wheat("map-reduce-wheat-2d", empty, path, "map-reduce/map-reduce-wheat-2.arr", "recommend", 1),
    mk-wheat("map-reduce-wheat-2e", empty, path, "map-reduce/map-reduce-wheat-2.arr", "popular-pairs", 1),

    mk-chaff("map-reduce-chaff-1a", empty, path, "map-reduce/map-reduce-chaff-each-file-separate.arr", "map-reduce", 1),
    mk-chaff("map-reduce-chaff-1b", empty, path, "map-reduce/map-reduce-chaff-each-file-separate.arr", "anagram-map", 1),
    mk-chaff("map-reduce-chaff-1c", empty, path, "map-reduce/map-reduce-chaff-each-file-separate.arr", "anagram-reduce", 1),
    mk-chaff("map-reduce-chaff-1d", empty, path, "map-reduce/map-reduce-chaff-each-file-separate.arr", "recommend", 1),
    mk-chaff("map-reduce-chaff-1e", empty, path, "map-reduce/map-reduce-chaff-each-file-separate.arr", "popular-pairs", 1),
    mk-chaff("map-reduce-chaff-2", empty, path, "map-reduce/map-reduce-chaff-nile-adds-all-books.arr", "recommend", 1),
    mk-chaff("map-reduce-chaff-3", empty, path, "map-reduce/map-reduce-chaff-nile-recommend-only-returns-one-book.arr", "recommend", 1),
    mk-chaff("map-reduce-chaff-4", empty, path, "map-reduce/map-reduce-chaff-with-duplicates.arr", "anagram-reduce", 1),
    mk-chaff("map-reduce-chaff-5", empty, path, "map-reduce/map-reduce-chaff-case-insensitive.arr", "anagram-map", 1),
    mk-chaff("map-reduce-chaff-6", empty, path, "map-reduce/map-reduce-chaff-each-tag-unique.arr", "anagram-map", 1),
    mk-chaff("map-reduce-chaff-7", empty, path, "map-reduce/map-reduce-chaff-nile-duplicate-pairs.arr", "popular-pairs", 1),
    mk-chaff("map-reduce-chaff-8", empty, path, "map-reduce/map-reduce-chaff-nile-popular-pairs-only-returns-one-book.arr", "popular-pairs", 1),

    ]
end

spec = build-graders("submission/assignment.arr")
