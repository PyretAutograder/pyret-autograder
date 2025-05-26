provide:
  run-chaff,
  run-wheat,
  run-functional
end

import file("./runners.arr") as A

import json as J
include string-dict

include file("./profiling.arr")

fun run-chaff(student-path, chaff-path, fun-name):
  time-ctx = init-time()

  tests = A.run-with-alternate-impl(student-path, chaff-path, fun-name)
  tests-time = time(time-ctx)

  passed = tests.get("passed").n().v
  total = tests.get("total").n().v

  process-time = time(time-ctx)
  spy "run-chaff": tests-time, process-time end

  [string-dict:
    "name", fun-name,
    "score", if not(passed == total): 1 else: 0 end,
    "description",
    if passed == total: "Tests did not identify known bad implementation"
    else: "Tests successfully identified known bad implementation" end
  ]
end

fun run-wheat(student-path, wheat-path, fun-name):
  time-ctx = init-time()

  tests = A.run-with-alternate-impl(student-path, wheat-path, fun-name)
  tests-time = time(time-ctx)

  passed = tests.get("passed").n().v
  total = tests.get("total").n().v

  process-time = time(time-ctx)
  spy "run-wheat": tests-time, process-time end

  [string-dict:
    "name", fun-name,
    "score", if passed == total: 1 else: 0 end,
    "description",
    if not(passed == total): "Some tests failed on known good implementation"
    else: "All tests passed on known good implementation" end
  ]
end

fun run-functional(student-path, reference-path, check-name):
  time-ctx = init-time()

  tests = A.run-extra-check(student-path, reference-path, check-name)
  tests-time = time(time-ctx)

  passed = tests.get("passed").n().v
  total = tests.get("total").n().v

  process-time = time(time-ctx)
  spy "run-functional": tests-time, process-time end

  [string-dict:
    "name", check-name,
    "score", if passed == total: 1 else: 0 end,
    "description",
    if not(passed == total): "Some instructor reference tests failed"
    else: "All instructor reference tests passed" end
  ]
end
