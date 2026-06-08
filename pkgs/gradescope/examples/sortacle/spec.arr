use context autograder-spec
provide: spec end

include graders

fun build-graders(path :: String):
  [list:
    mk-well-formed("wf", empty, path),

    mk-wheat("wheat-1-generate-input", [list: "wf"], path, "sortacle/sortacle-wheat.arr", "generate-input", 1),
    mk-wheat("wheat-1-is-valid", [list: "wf"], path, "sortacle/sortacle-wheat.arr", "is-valid", 1),
    mk-wheat("wheat-1-oracle", [list: "wf"], path, "sortacle/sortacle-wheat.arr", "oracle", 1),

    mk-wheat("wheat-2-generate-input", [list: "wf"], path, "sortacle/sortacle-wheat-2.arr", "generate-input", 1),
    mk-wheat("wheat-2-is-valid", [list: "wf"], path, "sortacle/sortacle-wheat-2.arr", "is-valid", 1),
    mk-wheat("wheat-2-oracle", [list: "wf"], path, "sortacle/sortacle-wheat-2.arr", "oracle", 1),

    mk-chaff("chaff-extra-person", [list: "wf"], path, "sortacle/sortacle-chaff-extra-person.arr", "generate-input", 1),
    mk-chaff("chaff-generate-fail-on-zero", [list: "wf"], path, "sortacle/sortacle-chaff-generate-fail-on-zero.arr", "generate-input", 1),
    mk-chaff("chaff-is-valid-comembership-issue", [list: "wf"], path, "sortacle/sortacle-chaff-is-valid-comembership-issue.arr", "is-valid", 1),
    mk-chaff("chaff-is-valid-one-valid", [list: "wf"], path, "sortacle/sortacle-chaff-is-valid-one-valid.arr", "is-valid", 1),
    mk-chaff("chaff-is-valid-only-compares-ages", [list: "wf"], path, "sortacle/sortacle-chaff-is-valid-only-compares-ages.arr", "is-valid", 1),
    mk-chaff("chaff-oracle-doesnt-allow-different-sort", [list: "wf"], path, "sortacle/sortacle-chaff-oracle-doesnt-allow-different-sort.arr", "oracle", 1),
    mk-chaff("chaff-oracle-doesnt-check-empty", [list: "wf"], path, "sortacle/sortacle-chaff-oracle-doesnt-check-empty.arr", "oracle", 1),
    mk-chaff("chaff-oracle-only-compares-ages", [list: "wf"], path, "sortacle/sortacle-chaff-oracle-only-compares-ages.arr", "oracle", 1),
  ]
end

spec = build-graders("submission/assignment.arr")
