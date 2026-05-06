provide: how-many, du-dir, can-find, fynd end

#| Doesn't obey: Returns false if no file found
    Instead only returns true
|#

fun how-many(directory :: Dir) -> Number:
  doc: "Finds the number of files in the directory tree."
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
  for fold(directories-size from directory.ds.length(), a-dir from directory.ds):
    directories-size + du-dir(a-dir)
  end
end



fun can-find(directory :: Dir, name :: String) -> Boolean:
  doc: "Determines whether a file with given name is in the directory tree."
  true
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
