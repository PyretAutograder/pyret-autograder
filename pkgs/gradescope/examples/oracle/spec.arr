use context autograder-spec
provide: spec end

include graders

fun build-graders(path :: String):
  [list:
    mk-well-formed("wf", empty, path),

    mk-wheat("wheat-1-is-valid", [list: "wf"], path, "oracle/oracle-wheat.arr",   "is-valid", 1),
    mk-wheat("wheat-1-oracle",   [list: "wf"], path, "oracle/oracle-wheat.arr",   "oracle",   1),
    mk-wheat("wheat-2-is-valid", [list: "wf"], path, "oracle/oracle-wheat-2.arr", "is-valid", 1),
    mk-wheat("wheat-2-oracle",   [list: "wf"], path, "oracle/oracle-wheat-2.arr", "oracle",   1),

    mk-chaff("chaff-is-valid-doesnt-check-dupes", [list: "wf"], path, "oracle/oracle-chaff-is-valid-doesnt-check-dupes.arr", "is-valid", 1),
    mk-chaff("chaff-is-valid-doesnt-check-size", [list: "wf"], path, "oracle/oracle-chaff-is-valid-doesnt-check-size.arr", "is-valid", 1),
    mk-chaff("chaff-is-valid-fail-on-empty", [list: "wf"], path, "oracle/oracle-chaff-is-valid-fail-on-empty.arr", "is-valid", 1),
    mk-chaff("chaff-is-valid-fail-on-one", [list: "wf"], path, "oracle/oracle-chaff-is-valid-fail-on-one.arr", "is-valid", 1),
    mk-chaff("chaff-oracle-doesnt-check-biggish", [list: "wf"], path, "oracle/oracle-chaff-oracle-doesnt-check-biggish.arr", "oracle", 1),
    mk-chaff("chaff-oracle-doesnt-check-dupes", [list: "wf"], path, "oracle/oracle-chaff-oracle-doesnt-check-dupes.arr", "oracle", 1),
    mk-chaff("chaff-oracle-doesnt-check-empty", [list: "wf"], path, "oracle/oracle-chaff-oracle-doesnt-check-empty.arr", "oracle", 1),
    mk-chaff("chaff-oracle-doesnt-check-size", [list: "wf"], path, "oracle/oracle-chaff-oracle-doesnt-check-size.arr", "oracle", 1),
    mk-chaff("chaff-oracle-uses-any-or", [list: "wf"], path, "oracle/oracle-chaff-oracle-uses-any-or.arr", "oracle", 1),
  ]
end

spec = build-graders("submission/assignment.arr")
