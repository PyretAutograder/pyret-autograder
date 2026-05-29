use context autograder-spec
provide: spec end

include graders

fun build-graders(path :: String):
  [list:
    mk-well-formed("wf", empty, path),

    # Wheats — run student tests against two correct implementations
    mk-wheat("wheat-1-take",              [list: "wf"], path, "contfracs/contfracs-wheat.arr",   "take",               1),
    mk-wheat("wheat-1-repeating-stream",  [list: "wf"], path, "contfracs/contfracs-wheat.arr",   "repeating-stream",   1),
    mk-wheat("wheat-1-fraction-stream",   [list: "wf"], path, "contfracs/contfracs-wheat.arr",   "fraction-stream",    1),
    mk-wheat("wheat-1-threshold",         [list: "wf"], path, "contfracs/contfracs-wheat.arr",   "threshold",          1),
    mk-wheat("wheat-1-cf-phi",            [list: "wf"], path, "contfracs/contfracs-wheat.arr",   "cf-phi",             1),
    mk-wheat("wheat-1-cf-e",              [list: "wf"], path, "contfracs/contfracs-wheat.arr",   "cf-e",               1),
    mk-wheat("wheat-1-terminating",       [list: "wf"], path, "contfracs/contfracs-wheat.arr",   "terminating-stream", 1),
    mk-wheat("wheat-1-repeating-opt",     [list: "wf"], path, "contfracs/contfracs-wheat.arr",   "repeating-stream-opt", 1),
    mk-wheat("wheat-1-fraction-opt",      [list: "wf"], path, "contfracs/contfracs-wheat.arr",   "fraction-stream-opt", 1),
    mk-wheat("wheat-1-threshold-opt",     [list: "wf"], path, "contfracs/contfracs-wheat.arr",   "threshold-opt",      1),
    mk-wheat("wheat-1-cf-phi-opt",        [list: "wf"], path, "contfracs/contfracs-wheat.arr",   "cf-phi-opt",         1),
    mk-wheat("wheat-1-cf-e-opt",          [list: "wf"], path, "contfracs/contfracs-wheat.arr",   "cf-e-opt",           1),
    mk-wheat("wheat-1-cf-pi-opt",         [list: "wf"], path, "contfracs/contfracs-wheat.arr",   "cf-pi-opt",          1),

    mk-wheat("wheat-2-take",              [list: "wf"], path, "contfracs/contfracs-wheat-2.arr", "take",               1),
    mk-wheat("wheat-2-repeating-stream",  [list: "wf"], path, "contfracs/contfracs-wheat-2.arr", "repeating-stream",   1),
    mk-wheat("wheat-2-fraction-stream",   [list: "wf"], path, "contfracs/contfracs-wheat-2.arr", "fraction-stream",    1),
    mk-wheat("wheat-2-threshold",         [list: "wf"], path, "contfracs/contfracs-wheat-2.arr", "threshold",          1),
    mk-wheat("wheat-2-cf-phi",            [list: "wf"], path, "contfracs/contfracs-wheat-2.arr", "cf-phi",             1),
    mk-wheat("wheat-2-cf-e",              [list: "wf"], path, "contfracs/contfracs-wheat-2.arr", "cf-e",               1),
    mk-wheat("wheat-2-terminating",       [list: "wf"], path, "contfracs/contfracs-wheat-2.arr", "terminating-stream", 1),
    mk-wheat("wheat-2-repeating-opt",     [list: "wf"], path, "contfracs/contfracs-wheat-2.arr", "repeating-stream-opt", 1),
    mk-wheat("wheat-2-fraction-opt",      [list: "wf"], path, "contfracs/contfracs-wheat-2.arr", "fraction-stream-opt", 1),
    mk-wheat("wheat-2-threshold-opt",     [list: "wf"], path, "contfracs/contfracs-wheat-2.arr", "threshold-opt",      1),
    mk-wheat("wheat-2-cf-phi-opt",        [list: "wf"], path, "contfracs/contfracs-wheat-2.arr", "cf-phi-opt",         1),
    mk-wheat("wheat-2-cf-e-opt",          [list: "wf"], path, "contfracs/contfracs-wheat-2.arr", "cf-e-opt",           1),
    mk-wheat("wheat-2-cf-pi-opt",         [list: "wf"], path, "contfracs/contfracs-wheat-2.arr", "cf-pi-opt",          1),

    # Chaffs — run student tests against subtly broken implementations
    mk-chaff("chaff-take-zero",         [list: "wf"], path, "contfracs/contfracs-take-fails-on-zero.arr",       "take",               1),
    mk-chaff("chaff-take-none",         [list: "wf"], path, "contfracs/contfracs-take-truncates-at-none.arr",   "take",               1),
    mk-chaff("chaff-repeating-twice",   [list: "wf"], path, "contfracs/contfracs-repeating-only-twice.arr",     "repeating-stream",   1),
    mk-chaff("chaff-fraction-neg",      [list: "wf"], path, "contfracs/contfracs-fraction-fails-when-first-negative.arr", "fraction-stream", 1),
    mk-chaff("chaff-fraction-neg-opt",  [list: "wf"], path, "contfracs/contfracs-fraction-fails-when-first-negative.arr", "fraction-stream-opt", 1),
    mk-chaff("chaff-fraction-all-none", [list: "wf"], path, "contfracs/contfracs-fraction-opt-fails-all-nones.arr",  "fraction-stream-opt", 1),
    mk-chaff("chaff-fraction-at-none",  [list: "wf"], path, "contfracs/contfracs-fractions-opt-fail-at-none.arr",    "fraction-stream-opt", 1),
    mk-chaff("chaff-threshold-incl",    [list: "wf"], path, "contfracs/contfracs-threshold-inclusive.arr",          "threshold",          1),
    mk-chaff("chaff-threshold-opt-incl",[list: "wf"], path, "contfracs/contfracs-threshold-inclusive.arr",          "threshold-opt",      1),
    mk-chaff("chaff-threshold-no-raise",[list: "wf"], path, "contfracs/contfracs-threshold-opt-doesnt-raise.arr",   "threshold-opt",      1),
    mk-chaff("chaff-threshold-all-none",[list: "wf"], path, "contfracs/contfracs-threshold-opt-fails-all-nones.arr","threshold-opt",      1),
    mk-chaff("chaff-terminating-end",   [list: "wf"], path, "contfracs/contfracs-terminating-fails-at-end.arr",     "terminating-stream", 1),
    mk-chaff("chaff-phi-wrong",         [list: "wf"], path, "contfracs/contfracs-phi-wrong.arr",                    "cf-phi",             1),
    mk-chaff("chaff-phi-opt-wrong",     [list: "wf"], path, "contfracs/contfracs-phi-opt-wrong.arr",                "cf-phi-opt",         1),
    mk-chaff("chaff-e-wrong",           [list: "wf"], path, "contfracs/contfracs-e-wrong.arr",                      "cf-e",               1),
    mk-chaff("chaff-e-opt-wrong",       [list: "wf"], path, "contfracs/contfracs-e-opt-wrong.arr",                  "cf-e-opt",           1),
    mk-chaff("chaff-pi-opt-four",       [list: "wf"], path, "contfracs/contfracs-pi-opt-only-four.arr",             "cf-pi-opt",          1),
  ]
end

spec = build-graders("submission/assignment.arr")
