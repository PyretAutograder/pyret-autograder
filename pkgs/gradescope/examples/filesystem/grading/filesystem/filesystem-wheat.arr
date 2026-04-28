provide: how-many, du-dir, can-find, fynd end

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
end
