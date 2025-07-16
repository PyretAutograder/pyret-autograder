import lists as L
import string-dict as SD

provide:
  unique,
  has-duplicates,
  list-to-stringdict,
end

fun unique<T>(lst :: List<T>) -> List<T>:
  doc: "Returns a new list with only unique elements."

  fun helper(remaining :: List<T>, seen :: List<T>) -> List<T>:
    cases (List<T>) remaining:
      | empty => seen
      | link(first, rest) =>
        if seen.member(first):
          helper(rest, seen)
        else:
          helper(rest, seen + [list: first])
        end
    end
  end
  helper(lst, [list:])
end

fun has-duplicates<T>(lst :: List<T>) -> Boolean:
  doc: "Determines if the list contains any duplicate elements."
  
  L.length(lst) > L.length(unique(lst))
end

fun list-to-stringdict<T>(l :: List<{String; T;}>) -> SD.StringDict<T>:
  doc: ```
    Converts a list of tuples to a string dictionary where for each tuple the:
    - first element is the key
    - second element is the value
  ```

  for fold(base from [SD.string-dict:], {key; val;} from l):
    base.set(key, val)
  end
end

