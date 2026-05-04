use context autograder-spec
provide: spec end

include graders

fun build-graders(path :: String):
  [list:

    mk-wheat("sortacle-wheat-1a", empty, path, "sortacle/sortacle-wheat.arr", "generate-input", 1),
    mk-wheat("sortacle-wheat-1b", empty, path, "sortacle/sortacle-wheat.arr", "is-valid", 1),
    mk-wheat("sortacle-wheat-1c", empty, path, "sortacle/sortacle-wheat.arr", "oracle", 1),

    mk-wheat("sortacle-wheat-2a", empty, path, "sortacle/sortacle-wheat-2.arr", "generate-input", 1),
    mk-wheat("sortacle-wheat-2b", empty, path, "sortacle/sortacle-wheat-2.arr", "is-valid", 1),
    mk-wheat("sortacle-wheat-2c", empty, path, "sortacle/sortacle-wheat-2.arr", "oracle", 1),

    mk-chaff("sortacle-chaff-1a", empty, path, "sortacle/sortacle-chaff-extra-person.arr", "generate-input", 1),
    mk-chaff("sortacle-chaff-1b", empty, path, "sortacle/sortacle-chaff-extra-person.arr", "is-valid", 1),
    mk-chaff("sortacle-chaff-1c", empty, path, "sortacle/sortacle-chaff-extra-person.arr", "oracle", 1),

    mk-chaff("sortacle-chaff-2a", empty, path, "sortacle/sortacle-chaff-generate-fail-on-zero.arr", "generate-input", 1),
    mk-chaff("sortacle-chaff-2b", empty, path, "sortacle/sortacle-chaff-generate-fail-on-zero.arr", "is-valid", 1),
    mk-chaff("sortacle-chaff-2c", empty, path, "sortacle/sortacle-chaff-generate-fail-on-zero.arr", "oracle", 1),

    mk-chaff("sortacle-chaff-3a", empty, path, "sortacle/sortacle-chaff-is-valid-comembership-issue.arr", "generate-input", 1),
    mk-chaff("sortacle-chaff-3b", empty, path, "sortacle/sortacle-chaff-is-valid-comembership-issue.arr", "is-valid", 1),
    mk-chaff("sortacle-chaff-3c", empty, path, "sortacle/sortacle-chaff-is-valid-comembership-issue.arr", "oracle", 1),

    mk-chaff("sortacle-chaff-4a", empty, path, "sortacle/sortacle-chaff-is-valid-one-valid.arr", "generate-input", 1),
    mk-chaff("sortacle-chaff-4b", empty, path, "sortacle/sortacle-chaff-is-valid-one-valid.arr", "is-valid", 1),
    mk-chaff("sortacle-chaff-4c", empty, path, "sortacle/sortacle-chaff-is-valid-one-valid.arr", "oracle", 1),

    mk-chaff("sortacle-chaff-5a", empty, path, "sortacle/sortacle-chaff-is-valid-only-compares-ages.arr", "generate-input", 1),
    mk-chaff("sortacle-chaff-5b", empty, path, "sortacle/sortacle-chaff-is-valid-only-compares-ages.arr", "is-valid", 1),
    mk-chaff("sortacle-chaff-5c", empty, path, "sortacle/sortacle-chaff-is-valid-only-compares-ages.arr", "oracle", 1),

    mk-chaff("sortacle-chaff-6a", empty, path, "sortacle/sortacle-chaff-oracle-doesnt-allow-different-sort.arr", "generate-input", 1),
    mk-chaff("sortacle-chaff-6b", empty, path, "sortacle/sortacle-chaff-oracle-doesnt-allow-different-sort.arr", "is-valid", 1),
    mk-chaff("sortacle-chaff-6c", empty, path, "sortacle/sortacle-chaff-oracle-doesnt-allow-different-sort.arr", "oracle", 1),

    mk-chaff("sortacle-chaff-7a", empty, path, "sortacle/sortacle-chaff-oracle-doesnt-check-empty.arr", "generate-input", 1),
    mk-chaff("sortacle-chaff-7b", empty, path, "sortacle/sortacle-chaff-oracle-doesnt-check-empty.arr", "is-valid", 1),
    mk-chaff("sortacle-chaff-7c", empty, path, "sortacle/sortacle-chaff-oracle-doesnt-check-empty.arr", "oracle", 1),

    mk-chaff("sortacle-chaff-8a", empty, path, "sortacle/sortacle-chaff-oracle-only-compares-ages.arr", "generate-input", 1),
    mk-chaff("sortacle-chaff-8b", empty, path, "sortacle/sortacle-chaff-oracle-only-compares-ages.arr", "is-valid", 1),
    mk-chaff("sortacle-chaff-8c", empty, path, "sortacle/sortacle-chaff-oracle-only-compares-ages.arr", "oracle", 1),

    ]
end

spec = build-graders("submission/assignment.arr")
