provide: how-many, du-dir, can-find, fynd end
# END HEADER

include file("submission/assignment-support.arr")
import distinct, foldl, append, any, length from lists
import list-to-set from sets

# ---- reference implementation ----

fun how-many(directory :: Dir) -> Number:
  doc: "Finds the number of files in the directory tree."
  # Fold over sub-directories, starting with number of files in current directory
  for fold(num-files from directory.fs.length(), sub-dir from directory.ds):
    num-files + how-many(sub-dir)
  end
end

fun du-dir(directory :: Dir) -> Number:
  doc: "Finds the total size of the directory tree."
  # Find size of files in current directory
  for fold(files-size from directory.fs.length(), a-file from directory.fs):
    files-size + a-file.size()
  end
  +
  # Find size of sub-directories in current directory
  for fold(directories-size from directory.ds.length(), a-dir from directory.ds):
    directories-size + du-dir(a-dir)
  end
end

fun can-find(directory :: Dir, name :: String) -> Boolean:
  doc: "Determines whether a file with given name is in the directory tree."
  # Check if it's in current directory
  for any(a-file from directory.fs):
    a-file.name == name
  end
  or
  # Check if it's in sub-directories
  for any(a-dir from directory.ds):
    can-find(a-dir, name)
  end
end

fun fynd(directory :: Dir, name :: String) -> List<Path>:
  doc: "Finds all instances of files with given name in the directory tree."
  sub-dir-paths :: List<Path> =
    directory.ds
    ^ map(fynd(_, name), _) # Recur on sub-dirs
    ^ foldl(append, empty, _) # Combine results into one list
    ^ map(link(directory.name, _), _) # Add current directory to paths

  # If file is in current directory, add new path
  if directory.fs.map(_.name).member(name):
    link([list: directory.name], sub-dir-paths)
  else:
    sub-dir-paths
  end
end

# ---- test fixtures ----

fun string-of-len(l :: Number) -> String:
  if l == 0:
    ""
  else:
    "a" + string-of-len(l - 1)
  end
end

FS1 = dir("empty", empty, empty)

FS2 = dir("top", empty, [list:
    file("a", string-of-len(1)),
    file("b", string-of-len(2)),
    file("c", string-of-len(3)),
    file("d", string-of-len(4))])

FS3 = dir("top",
  [list:
    dir("mid-a", empty, [list:
        file("a", string-of-len(1)),
        file("b", string-of-len(2)),
        file("c", string-of-len(3)),
        file("d", string-of-len(4))]),
    dir("mid-b",
      [list:
        dir("low-b-a", empty, [list: file("a", string-of-len(9000))]),
        dir("low-b-b", empty, [list: file("powerlevel", string-of-len(9001))])],
      [list:
        file("a", string-of-len(1)),
        file("b", string-of-len(2)),
        file("c", string-of-len(3))])],
  [list: file("a", string-of-len(4)),
    file("b", string-of-len(5))])

FS4 = dir("top", [list:
    dir("mid-a", empty, [list:
        file("a", string-of-len(1)),
        file("b", string-of-len(2)),
        file("c", string-of-len(3)),
        file("d", string-of-len(4))]),
    dir("mid-b", [list:
        dir("low-b-a", empty, [list: file("a", string-of-len(9000))]),
        dir("low-b-b", empty, [list: file("powerlevel", string-of-len(9001))])],
      empty)],
  empty)

FS5 = dir("top", [list:
    dir("mid-a", [list:
        dir("low-a-a", [list:
            dir("lower-a-a-a", empty, empty),
            dir("lower-a-a-b", [list:
                dir("lowest-a-a-b-a", empty, empty)], empty),
            dir("lower-a-a-c", empty, empty)], empty),
        dir("low-a-b", empty, empty),
        dir("low-a-c", empty, empty)], empty),
    dir("mid-b", [list:
        dir("low-b-a", empty, empty)], empty),
    dir("mid-c", empty, empty)], empty)

FS6 =
  dir("top", [list:
      dir("mid", [list:
          dir("low", [list:
              dir("lowest", empty, [list:
                  file("d", string-of-len(5))])],
            empty)],
        empty)],
    empty)

# ---- tests, routed per function under test ----

check "how-many":
  # should be 0 for empty dir
  how-many(FS1) is 0
  # should be 4 for a dir with 4 files on top level
  how-many(FS2) is 4
  # handles subdir recursion by counting every leaf
  how-many(FS3) is 11
  # handles subdir recursion by handling missing leaves
  how-many(FS4) is 6
  # does not count dirs as files
  how-many(FS5) is 0
end

check "du-dir":
  # du-dir should be 0 for an empty dir
  du-dir(FS1) is 0
  # sums the file-sizes correctly
  du-dir(FS2) is 14
  # recurs through the subdirs properly and adds both length of file list and
  # length of dirs list
  du-dir(FS3) is (18001 + 25 + 11 + 4)
  # recurs through subdirs some of which have files and some of which do not
  du-dir(FS4) is (18001 + 10 + 6 + 4)
  # recurs through subdirs, handling the case of no files
  du-dir(FS5) is 11
end

check "can-find":
  # can-find gets false for a file not found in a one level dir
  can-find(FS2, "foo") is false
  # finds first file in a one level dir
  can-find(FS2, "a") is true
  # finds a file within a one level dir
  can-find(FS2, "b") is true
  # finds first file within a 3 level tree
  can-find(FS3, "a") is true
  # finds a deeper file within the subdirs of a 3 level tree
  can-find(FS3, "c") is true
  # finds a file within the sub-subdirs of a 3 level tree
  can-find(FS3, "powerlevel") is true
  # returns false for a file not in the dir
  can-find(FS3, "foo") is false
  # finds lower level element in a large tree
  can-find(FS4, "a") is true
  # does not find the name of the top-level directory
  can-find(FS5, "top") is false
  # finds files but not directories
  can-find(FS4, "mid-a") is false
end

check "fynd":
  # file exists at every depth
  solutions1 = [list: [list: "top", "mid-a"], [list: "top", "mid-b", "low-b-a"],
    [list: "top", "mid-b"], [list: "top"]]
  fold(lam(acc, cur): acc and solutions1.member(cur) end, true, fynd(FS3, "a"))
    is true
  list-to-set(solutions1) is list-to-set(fynd(FS3, "a"))

  # file exists in multiple depths including root
  solutions2 = [list: [list: "top", "mid-a"], [list: "top", "mid-b"],
    [list: "top"]]
  fold(lam(acc, cur): acc and solutions2.member(cur) end, true, fynd(FS3, "b"))
    is true
  list-to-set(solutions2) is list-to-set(fynd(FS3, "b"))

  # file exists in only middle subdirectories
  solutions3 = [list: [list: "top", "mid-a"], [list: "top", "mid-b"]]
  fold(lam(acc, cur): acc and solutions3.member(cur) end, true, fynd(FS3, "c"))
    is true
  list-to-set(solutions3) is list-to-set(fynd(FS3, "c"))

  # correct path to file in many empty directories
  fynd(FS6, "d") is [list: [list: "top", "mid", "low", "lowest"]]

  # does not return any paths when file is not found
  fynd(FS3, "e") is empty
  fynd(FS5, "a") is empty
  fynd(FS5, "b") is empty

  # returns empty if only directories match search
  fynd(FS6, "mid") is empty

  # does not return any paths for an empty tree
  fynd(FS1, "top") is empty
end
