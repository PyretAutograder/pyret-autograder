use context autograder-spec
provide: spec end

include graders

fun build-graders(path :: String):
  [list:

    mk-wheat("oracle-wheat-1a", empty, path, "oracle/oracle-wheat.arr", "is-valid", 1),
    mk-wheat("oracle-wheat-1b", empty, path, "oracle/oracle-wheat.arr", "oracle", 1),

    mk-wheat("oracle-wheat-2a", empty, path, "oracle/oracle-wheat-2.arr", "is-valid", 1),
    mk-wheat("oracle-wheat-2b", empty, path, "oracle/oracle-wheat-2.arr", "oracle", 1),

    mk-chaff("oracle-chaff-1", empty, path, "oracle/oracle-chaff-is-valid-doesnt-check-dupes.arr", "is-valid", 1),
    mk-chaff("oracle-chaff-2", empty, path, "oracle/oracle-chaff-is-valid-doesnt-check-size.arr", "is-valid", 1),
    mk-chaff("oracle-chaff-3", empty, path, "oracle/oracle-chaff-is-valid-fail-on-empty.arr", "is-valid", 1),
    mk-chaff("oracle-chaff-4", empty, path, "oracle/oracle-chaff-is-valid-fail-on-one.arr", "is-valid", 1),
    mk-chaff("oracle-chaff-5", empty, path, "oracle/oracle-chaff-oracle-doesnt-check-biggish.arr", "oracle", 1),
    mk-chaff("oracle-chaff-6", empty, path, "oracle/oracle-chaff-oracle-doesnt-check-dupes.arr", "oracle", 1),
    mk-chaff("oracle-chaff-7", empty, path, "oracle/oracle-chaff-oracle-doesnt-check-empty.arr", "oracle", 1),
    mk-chaff("oracle-chaff-8", empty, path, "oracle/oracle-chaff-oracle-doesnt-check-size.arr", "oracle", 1),
    mk-chaff("oracle-chaff-9", empty, path, "oracle/oracle-chaff-oracle-uses-any-or.arr", "oracle", 1),

    ]
end

spec = build-graders("submission/assignment.arr")
