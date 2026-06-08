#| wheat (tdelvecc, Aug 31, 2020): 
    can-find: raises an error when two files have the same name in the same directory.
    fynd: raises an error when two files have the same name in the same directory.
    Flips the order of the output list in fynd.
    Search "WHEAT DIFFERENCE" for changed code.
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

fun can-find(directory :: Dir, name :: String) -> Boolean block:
  doc: "Determines whether a file with given name is in the directory tree."
  # WHEAT DIFFERENCE: errors when two files have same name
  unique-file-name-count = directory.fs
    ^ map({(x :: File): x.name}, _)
    ^ distinct
    ^ length
  when (unique-file-name-count <> directory.fs.length()):
    raise("Two files with same name in one directory")
  end
  
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

fun fynd(directory :: Dir, name :: String) -> List<Path> block:
  doc: "Finds all instances of files with given name in the directory tree."
  fun helper(shadow directory :: Dir) -> List<Path> block:
    # WHEAT DIFFERENCE: errors when two files have same name
    unique-file-name-count = directory.fs
      ^ map({(x :: File): x.name}, _)
      ^ distinct
      ^ length
    when (unique-file-name-count <> directory.fs.length()):
      raise("Two files with same name in one directory")
    end

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
  
  # WHEAT DIFFERENCE: Reverses the order of the output
  helper(directory).reverse()
end