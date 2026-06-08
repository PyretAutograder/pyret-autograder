#|
    Does not obey the following property: If can-find(d, f) is false, it produces empty.
    Instead: Just returns the directory queried.

    NOTE: In the source this bug lived in a `fynd-wrapper` that the module
    re-exported as `fynd`.  Because the autograder merges alternate
    implementations by top-level function NAME (not by what the module
    happens to re-export), the bug is inlined directly into `fynd` here, with
    the correct recursion moved into the helper `fynd-rec`.
|#

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
  # BUG: when the file cannot be found, returns the directory queried
  #      instead of empty.
  if can-find(directory, name):
    fynd-rec(directory, name)
  else:
    [list: directory]
  end
end

fun fynd-rec(directory :: Dir, name :: String) -> List<Path>:
  doc: "Finds all instances of files with given name in the directory tree."
  sub-dir-paths :: List<Path> =
    directory.ds
    ^ map(fynd-rec(_, name), _) # Recur on sub-dirs
    ^ lists.foldl(lists.append, empty, _) # Combine results into one list
    ^ map(lists.link(directory.name, _), _) # Add current directory to paths

  # If file is in current directory, add new path
  if directory.fs.map(_.name).member(name):
    lists.link([list: directory.name], sub-dir-paths)
  else:
    sub-dir-paths
  end
end
