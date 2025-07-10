import lists as L
import string-dict as SD

provide:
  unique,
  has-duplicates,
  list-to-stringdict,
end

fun unique<T>(lst :: List<T>) -> List<T>:
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
  L.length(lst) > L.length(unique(lst))
end

fun list-to-stringdict<T>(l :: List<{String; T;}>) -> SD.StringDict<T>:
  for fold(base from [SD.string-dict:], {key; val;} from l):
    base.set(key, val)
  end
end

