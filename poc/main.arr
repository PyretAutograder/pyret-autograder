import json as J
include file("./lib.arr")

print(J.tojson([list:
      run-chaff("../examples/gcd.arr", "../examples/gcd/chaff.arr", "gcd").set("name", "gcd-chaff-1"),
      run-wheat("../examples/gcd.arr", "../examples/gcd/wheat.arr", "gcd").set("name", "gcd-wheat-1"),
      run-functional("../examples/gcd.arr", "../examples/gcd/functional.arr", "gcd-reference-tests")
    ]).serialize())
print("\n")
