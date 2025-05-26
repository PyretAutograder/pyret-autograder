import json as J
include file("./lib.arr")

include file("./profiling.arr")

time-ctx = init-time()

chaff-result = run-chaff("examples/gcd.arr", "examples/gcd/chaff.arr", "gcd").set("name", "gcd-chaff-1")
chaff-result-time = time(time-ctx)

wheat-result = run-wheat("examples/gcd.arr", "examples/gcd/wheat.arr", "gcd").set("name", "gcd-wheat-1")
wheat-result-time = time(time-ctx)

functional-result = run-functional("examples/gcd.arr", "examples/gcd/functional.arr", "gcd-reference-tests")
functional-result-time = time(time-ctx)

print(J.tojson([list: chaff-result, wheat-result, functional-result]).serialize())
print("\n")

print-time = time(time-ctx)

spy "overall": chaff-result-time, wheat-result-time, functional-result-time end
