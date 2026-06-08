use context autograder-spec
provide: spec end

include graders

fun build-graders(path :: String):
  [list:
    mk-well-formed("wf", empty, path),

    mk-wheat("wheat-1-how-many", [list: "wf"], path, "filesystem/filesystem-wheat.arr",   "how-many", 1),
    mk-wheat("wheat-1-du-dir",   [list: "wf"], path, "filesystem/filesystem-wheat.arr",   "du-dir",   1),
    mk-wheat("wheat-1-can-find", [list: "wf"], path, "filesystem/filesystem-wheat.arr",   "can-find", 1),
    mk-wheat("wheat-1-fynd",     [list: "wf"], path, "filesystem/filesystem-wheat.arr",   "fynd",     1),

    mk-wheat("wheat-2-how-many", [list: "wf"], path, "filesystem/filesystem-wheat-2.arr", "how-many", 1),
    mk-wheat("wheat-2-du-dir",   [list: "wf"], path, "filesystem/filesystem-wheat-2.arr", "du-dir",   1),
    mk-wheat("wheat-2-can-find", [list: "wf"], path, "filesystem/filesystem-wheat-2.arr", "can-find", 1),
    mk-wheat("wheat-2-fynd",     [list: "wf"], path, "filesystem/filesystem-wheat-2.arr", "fynd",     1),

    mk-chaff("chaff-can-always-find",         [list: "wf"], path, "filesystem/filesystem-chaff-can-always-find.arr",            "can-find", 1),
    mk-chaff("chaff-can-find-doesnt-check-root", [list: "wf"], path, "filesystem/filesystem-chaff-can-find-doesnt-check-root.arr", "can-find", 1),
    mk-chaff("chaff-du-dir-only-file-and-dir-size", [list: "wf"], path, "filesystem/filesystem-chaff-du-dir-only-file-and-dir-size.arr", "du-dir", 1),
    mk-chaff("chaff-fynd-dir-when-cannot-find", [list: "wf"], path, "filesystem/filesystem-chaff-fynd-dir-when-cannot-find.arr",  "fynd",     1),
    mk-chaff("chaff-how-many-counts-dirs-and-files", [list: "wf"], path, "filesystem/filesystem-chaff-how-many-counts-dirs-and-files.arr", "how-many", 1),
  ]
end

spec = build-graders("submission/assignment.arr")
