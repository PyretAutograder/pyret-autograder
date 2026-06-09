use context autograder-spec
provide: spec end

include graders

fun build-graders(path :: String):
  [list:
    mk-well-formed("wf", empty, path),

    mk-wheat("wheat-find-cursor",  [list: "wf"], path, "updater/updater-wheat.arr", "find-cursor",  1),
    mk-wheat("wheat-get-node-val", [list: "wf"], path, "updater/updater-wheat.arr", "get-node-val", 1),
    mk-wheat("wheat-to-tree",      [list: "wf"], path, "updater/updater-wheat.arr", "to-tree",      1),
    mk-wheat("wheat-up",           [list: "wf"], path, "updater/updater-wheat.arr", "up",           1),
    mk-wheat("wheat-down",         [list: "wf"], path, "updater/updater-wheat.arr", "down",         1),
    mk-wheat("wheat-left",         [list: "wf"], path, "updater/updater-wheat.arr", "left",         1),
    mk-wheat("wheat-right",        [list: "wf"], path, "updater/updater-wheat.arr", "right",        1),
    mk-wheat("wheat-update",       [list: "wf"], path, "updater/updater-wheat.arr", "update",       1),

    # find-cursor chaffs
    mk-chaff("chaff-find-cursor-bottom-to-top",    [list: "wf"], path, "updater/updater-find-cursor-bottom-to-top.arr",    "find-cursor", 1),
    mk-chaff("chaff-find-cursor-fails-when-missing", [list: "wf"], path, "updater/updater-find-cursor-fails-when-missing.arr", "find-cursor", 1),
    mk-chaff("chaff-find-cursor-right-to-left",    [list: "wf"], path, "updater/updater-find-cursor-right-to-left.arr",    "find-cursor", 1),

    # get-node-val chaff
    mk-chaff("chaff-get-node-fails-on-mt", [list: "wf"], path, "updater/updater-get-node-fails-on-mt.arr", "get-node-val", 1),

    # movement chaffs
    mk-chaff("chaff-illegal-down-fails",     [list: "wf"], path, "updater/updater-illegal-down-fails.arr",     "down", 1),
    mk-chaff("chaff-illegal-left-fails",     [list: "wf"], path, "updater/updater-illegal-left-fails.arr",     "left", 1),
    mk-chaff("chaff-illegal-right-fails",    [list: "wf"], path, "updater/updater-illegal-right-fails.arr",    "right", 1),
    mk-chaff("chaff-illegal-up-fails",       [list: "wf"], path, "updater/updater-illegal-up-fails.arr",       "up", 1),
    mk-chaff("chaff-illegal-movement-fails", [list: "wf"], path, "updater/updater-illegal-movement-fails.arr", "up", 1),
    mk-chaff("chaff-up-then-up-fails",       [list: "wf"], path, "updater/updater-up-then-up-fails.arr",       "up", 1),

    # to-tree chaff
    mk-chaff("chaff-to-tree-doesnt-filter-mts", [list: "wf"], path, "updater/updater-to-tree-doesnt-filter-mts.arr", "to-tree", 1),

    # update chaffs
    mk-chaff("chaff-update-then-anything-fails", [list: "wf"], path, "updater/updater-update-then-anything-fails.arr", "update", 1),
    mk-chaff("chaff-update-then-down-fails",     [list: "wf"], path, "updater/updater-update-then-down-fails.arr",     "update", 1),
    mk-chaff("chaff-update-then-horizontal",     [list: "wf"], path, "updater/updater-update-then-horizontal.arr",     "update", 1),
    mk-chaff("chaff-update-then-up-fails",       [list: "wf"], path, "updater/updater-update-then-up-fails.arr",       "update", 1),
    mk-chaff("chaff-update-then-update-fails",   [list: "wf"], path, "updater/updater-update-then-update-fails.arr",   "update", 1),
  ]
end

spec = build-graders("submission/assignment.arr")
