provide:
  run-chaff,
  run-wheat,
  run-functional
end

import file("./runners.arr") as A

import json as J
include string-dict

fun run-chaff(student-path, chaff-path, fun-name):
  tests = A.run-with-alternate-impl(student-path, chaff-path, fun-name)
  passed = tests.get("passed").n().v
  total = tests.get("total").n().v

  [string-dict:
    "name", fun-name,
    "score", if not(passed == total): 1 else: 0 end,
    "description",
    if passed == total: "Tests did not identify known bad implementation"
    else: "Tests successfully identified known bad implementation" end
  ]
end

fun run-wheat(student-path, wheat-path, fun-name):
  tests = A.run-with-alternate-impl(student-path, wheat-path, fun-name)
  passed = tests.get("passed").n().v
  total = tests.get("total").n().v

  [string-dict:
    "name", fun-name,
    "score", if passed == total: 1 else: 0 end,
    "description",
    if not(passed == total): "Some tests failed on known good implementation"
    else: "All tests passed on known good implementation" end
  ]
end

fun run-functional(student-path, reference-path, check-name):
  tests = A.run-extra-check(student-path, reference-path, check-name)
  passed = tests.get("passed").n().v
  total = tests.get("total").n().v
  
  [string-dict:
    "name", check-name,
    "score", if passed == total: 1 else: 0 end,
    "description",
    if not(passed == total): "Some instructor reference tests failed"
    else: "All instructor reference tests passed" end
  ]
end
