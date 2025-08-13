import file("./meta/path-utils.arr") as P
include file("../src/main.arr")
include file("../src/grading-helpers.arr")

check "aggregate-to-flat":
  aggregated = [list:
    agg-guard("wf", "Wellformed Check", guard-blocked(output-markdown("WF BLOCK REASON"), none)),
    agg-test("gcd-self-test", "Self-Test on gcd", 2, test-skipped("wf")),
    agg-test("gcd-chaff-1", "Chaff for gcd", 1, test-skipped("wf")),
    agg-test("gcd-wheat-1", "Wheat for gcd", 2, test-skipped("wf")),
    agg-test("gcd-reference-tests", "Functional Test for gcd-reference-tests", 5, test-skipped("wf"))]

  flat-expected = [list:
    flat-agg-test("Self-Test on gcd", 2, 0, output-markdown("WF BLOCK REASON"), none),
    flat-agg-test("Chaff for gcd", 1, 0, output-markdown("WF BLOCK REASON"), none),
    flat-agg-test("Wheat for gcd", 2, 0, output-markdown("WF BLOCK REASON"), none),
    flat-agg-test("Functional Test for gcd-reference-tests", 5, 0, output-markdown("WF BLOCK REASON"), none)]
  aggregate-to-flat(aggregated) is flat-expected
end


