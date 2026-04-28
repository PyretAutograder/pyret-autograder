provide: how-many, du-dir, can-find, fynd end

#| 
Does not obey: The size of a directory is the sum of the sizes of its files and directories, the length of its fs list, and the length of its ds list.
Instead: The size of a directory is the sum of the sizes of its files and directories.
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
  for fold(files-size from 0, a-file from directory.fs):
    files-size + a-file.size()
  end
  +
  # Find size of sub-directories in current directory
  for fold(directories-size from 0, a-dir from directory.ds):
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


fun fynd(directory :: Dir, name :: String) -> List<Path>:
  doc: "Finds all instances of files with given name in the directory tree."
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
