use context autograder-spec
provide: spec end

include graders

fun build-graders(path :: String):
  [list:

    mk-wheat("filesystem-wheat-1a", empty, path, "filesystem/filesystem-wheat.arr", "how-many", 1),
    mk-wheat("filesystem-wheat-1b", empty, path, "filesystem/filesystem-wheat.arr", "du-dir", 1),
    mk-wheat("filesystem-wheat-1c", empty, path, "filesystem/filesystem-wheat.arr", "can-find", 1),
    mk-wheat("filesystem-wheat-1d", empty, path, "filesystem/filesystem-wheat.arr", "fynd", 1),

    mk-wheat("filesystem-wheat-2a", empty, path, "filesystem/filesystem-wheat-2.arr", "how-many", 1),
    mk-wheat("filesystem-wheat-2b", empty, path, "filesystem/filesystem-wheat-2.arr", "du-dir", 1),
    mk-wheat("filesystem-wheat-2c", empty, path, "filesystem/filesystem-wheat-2.arr", "can-find", 1),
    mk-wheat("filesystem-wheat-2d", empty, path, "filesystem/filesystem-wheat-2.arr", "fynd", 1),

    mk-chaff("filesystem-chaff-1", empty, path, "filesystem/filesystem-chaff-can-always-find.arr", "can-find", 1),
    mk-chaff("filesystem-chaff-2", empty, path, "filesystem/filesystem-chaff-can-find-doesnt-check-root.arr", "can-find", 1),
    mk-chaff("filesystem-chaff-3", empty, path, "filesystem/filesystem-chaff-du-dir-only-file-and-dir-size.arr", "du-dir", 1),
    mk-chaff("filesystem-chaff-4", empty, path, "filesystem/filesystem-chaff-fynd-dir-when-cannot-find.arr", "fynd", 1),
    mk-chaff("filesystem-chaff-6", empty, path, "filesystem/filesystem-chaff-how-many-counts-dirs-and-files.arr", "how-many", 1),

    ]
end

spec = build-graders("submission/assignment.arr")
