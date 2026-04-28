provide: how-many, du-dir, can-find, fynd end

data Dir:
 | dir(name :: String, ds :: List<Dir>, fs :: List<File>)
end

data File:
 | file(name :: String, content :: String)
    with:
    method size(self):
      string-length(self.content)
    end
    #|where:
  zero-size = file("test", "")
  zero-size.size() is 0
  one-size = file("test", "i")
  one-size.size() is 1
  ten-size = file("test", "aaaaaaaaaa")
  ten-size.size() is 10
  spaces-file = file("test", "    ")
  spaces-file.size() is 4|#
end

type Path = List<String>

fun count<A>(target :: A, a :: List<A>) -> Number:
  el-checker = lam(el, cnt):
    if el == target:
      cnt + 1
    else:
      cnt
    end
  end
  a.foldl(el-checker, 0)
end
 
fun lst-same-els<A>(a :: List<A>, b :: List<A>) -> Boolean:
  fun same-count(el, acc):
    acc and (count(el, a) == count(el, b))
  end
  (a.length() == b.length()) and a.foldl(same-count, true)
end


#| wheat (tdelvecc, Aug 31, 2020): 
    Basic wheat; follows specs without additional features.
|#

fun dag-checker(directory :: Dir) -> Boolean:
  doc: ```Checks whether directory is a DAG by checking if the number of distinct directories/files equals 
  the number of total directories/files.```
  all-dir = tree-flatten-dir(directory)
  all-files = tree-flatten-fil(directory)
  (lists.distinct(all-dir).length() == all-dir.length()) and (lists.distinct(all-files).length() == all-files.length())
end

fun tree-flatten-dir(directory :: Dir) -> List<Dir>:
  doc: "Helper function for creating a list of directories in the filesystem tree."
  sub-dirs = lists.fold(lam(nodes, child): tree-flatten-dir(child).append(nodes) end, empty, directory.ds)
  lists.link(directory, sub-dirs)
end

fun tree-flatten-fil(directory :: Dir) -> List<File>:
  doc: "Helper function for creating a list of files in the filesystem tree."
  sub-files = lists.fold(lam(nodes, child): tree-flatten-fil(child).append(nodes) end, empty, directory.ds)
  sub-files.append(directory.fs)
end

fun string-of-len(l :: Number):
  if l == 0:
    ""
  else:
    "a" + string-of-len(l - 1)
  end
#|where:
  string-of-len(0) is ""
  string-of-len(1) is "a"
  string-of-len(5) is "aaaaa" |#
end

# data
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
        dir("low-b-b", empty, [list: file("powerlevel",string-of-len(9001))])],
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

fun how-many(directory :: Dir) -> Number block:
  doc: "Finds the number of files in the directory tree."
  # Check if tree is a DAG
  #| when not(dag-checker(directory)):
    raise("A child node has more than one parent")
  end |#
  # Fold over sub-directories, starting with number of files in current directory
  for lists.fold(num-files from directory.fs.length(), sub-dir from directory.ds):
    num-files + how-many(sub-dir)
  end
  where:
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

fun du-dir(directory :: Dir) -> Number:
  doc: "Finds the total size of the directory tree."
  # Find size of files in current directory
  for lists.fold(files-size from directory.fs.length(), a-file from directory.fs):
    files-size + a-file.size()
  end
  +
  # Find size of sub-directories in current directory
  for lists.fold(directories-size from directory.ds.length(), a-dir from directory.ds):
    directories-size + du-dir(a-dir)
  end
  where:
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

fun can-find(directory :: Dir, name :: String) -> Boolean:
  doc: "Determines whether a file with given name is in the directory tree."
  # Check if it's in current directory
  for lists.any(a-file from directory.fs):
    a-file.name == name
  end
  or
  # Check if it's in sub-directories
  for lists.any(a-dir from directory.ds):
    can-find(a-dir, name)
  end
  where:
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

fun contains-identical-dirs(directory :: Dir) -> Boolean:
  doc: ```Checks whether a directory has two or more immediate subdirectories 
       with identical names.```
  unique-directories-name-count = directory.ds
    ^ lists.map({(x :: Dir): x.name}, _)
    ^ lists.distinct
    ^ lists.length
  if (unique-directories-name-count <> directory.ds.length()):
    true
  else:
    lists.fold({(r, d): r or contains-identical-dirs(d)}, false, directory.ds)
  end
end

fun fynd(directory :: Dir, name :: String) -> List<Path> block:
  doc: "Finds all instances of files with given name in the directory tree."

  # WHEAT DIFFERENCE: errors when 2+ direct subdirectories 
  #                   of a parent directory have the same name
  when contains-identical-dirs(directory):
    raise("Two directories with same name in one directory")
  end

  sub-dir-paths :: List<Path> =
    directory.ds
    ^ lists.map(fynd(_, name), _) # Recur on sub-dirs
    ^ lists.foldl(lists.append, empty, _) # Combine results into one list
    ^ lists.map(lists.link(directory.name, _), _) # Add current directory to paths
  
  # If file is in current directory, add new path
  if directory.fs.map(_.name).member(name):
    lists.link([list: directory.name], sub-dir-paths)
  else:
    sub-dir-paths
  end
  where:

    # tests normal fynd operation -- file exists in every depth:
  # finds correct paths for files that matches filename in 3 level tree
  solutions1 = [list: [list: "top", "mid-a"], [list: "top", "mid-b", "low-b-a"],
    [list: "top", "mid-b"], [list: "top"]]
  lists.fold(lam(acc, cur): acc and solutions1.member(cur) end, true, fynd(FS3, "a"))
    is true
  # finds every correct path for every file that matches filename in 
  # 3 level tree
  sets.list-to-set(solutions1) is sets.list-to-set(fynd(FS3, "a"))

  # tests normal fynd operation -- file exists in multiple depths including root
  # finds correct paths for every file that matches filename in 3 level tree
  solutions2 = [list: [list: "top", "mid-a"], [list: "top", "mid-b"], 
    [list: "top"]]
  lists.fold(lam(acc, cur): acc and solutions2.member(cur) end, true, fynd(FS3, "b"))
    is true

  sets.list-to-set(solutions2) is sets.list-to-set(fynd(FS3, "b"))

  # tests normal fynd operation -- file exists in only middle subdirs
  # finds correct paths for every file that matches filename in 3 level tree
  solutions3 = [list: [list: "top", "mid-a"], [list: "top", "mid-b"]]
  lists.fold(lam(acc, cur): acc and solutions3.member(cur) end, true, fynd(FS3, "c"))
    is true

  sets.list-to-set(solutions3) is sets.list-to-set(fynd(FS3, "c"))


  # fynd finds correct path to file in many empty dirs
  fynd(FS6, "d") is [list: [list: "top", "mid", "low", "lowest"]]

  # fynd does not return any paths when file not found
  fynd(FS3, "e") is empty
  fynd(FS5, "a") is empty
  fynd(FS5, "b") is empty

  # fynd returns empty if only dirs match search
  fynd(FS6, "mid") is empty

  # fynd doesn't return any paths for empty tree
  fynd(FS1, "top") is empty
end
