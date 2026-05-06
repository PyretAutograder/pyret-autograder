use context autograder-spec
provide: spec end

include graders

fun build-graders(path :: String):
  [list:
    mk-wheat("median-wheat-1", empty, path, "median/wheat-1.arr", "median", 1),

    mk-wheat("median-wheat-2", empty, path, "median/wheat-2.arr", "median", 1),

    mk-chaff("median-chaff-1", empty, path, "median/chaff-1.arr", "median", 1),
    mk-chaff("median-chaff-2", empty, path, "median/chaff-2.arr", "median", 1),
    mk-chaff("median-chaff-3", empty, path, "median/chaff-3.arr", "median", 1),
    mk-chaff("median-chaff-4", empty, path, "median/chaff-4.arr", "median", 1),
    mk-chaff("median-chaff-5", empty, path, "median/chaff-5.arr", "median", 1),
    ]
end

spec = build-graders("submission/assignment.arr")
