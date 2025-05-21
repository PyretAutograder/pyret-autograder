provide:
  unique,
  has-duplicates,
end

import lists as L


fun unique<T>(lst :: List<T>) -> List<T>:
  fun helper(remaining :: List<T>, seen :: List<T>):
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
  helper(lst, [list:]).reverse()
end

fun has-duplicates<T>(lst :: List<T>) -> Boolean:
  L.length(lst) > L.length(unique(lst))
end
