#|
  Copyright (C) 2025 ironmoon <me@ironmoon.dev>

  This file is part of pyret-autograder.

  pyret-autograder is free software: you can redistribute it and/or modify it
  under the terms of the GNU Lesser General Public License as published by the
  Free Software Foundation, either version 3 of the License, or (at your option)
  any later version.

  pyret-autograder is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License
  for more details.

  You should have received a copy of the GNU Lesser General Public License
  with pyret-autograder. If not, see <http://www.gnu.org/licenses/>.
|#
import lists as L
import string-dict as SD
import either as E

provide:
  unique,
  has-duplicates,
  list-to-stringdict,
  upcast,
  safe-divide,
  min,
  max,
  safe-inclusive-substring,
  filter_n
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

fun upcast<T>(x :: T) -> Any:
  x
end

fun safe-divide(a :: Number, b :: Number, default :: Number) -> Number:
  doc: "Divide the numbers if b != 0, otherwise return default"
  if b == 0:
    default
  else:
    a / b
  end
end

fun min(a :: Number, b :: Number) -> Number:
  doc: "Returns the smaller of the provided numbers."
  if a > b:
    b
  else:
    a
  end
end

fun max(a :: Number, b :: Number) -> Number:
  doc: "Returns the larger of the provided numbers."
  if a > b:
    a
  else:
    b
  end
end

fun safe-inclusive-substring(
  str :: String, start-index :: NumNonNegative, end-index :: Number
) -> String:
  doc: ```
    Takes the substring of a number in the range [start, end] where both indexes
    are inclusive. If the start index is larger than what the string contains,
    an empty string will be returned.
  ```
  len = string-length(str)
  ask:
    | start-index > end-index then: ""
    | start-index >= len then: ""
    | otherwise: string-substring(str, start-index, min(end-index + 1, len))
  end
end

fun filter_n<T>(
  f :: (Number, T -> Boolean), start :: Number, lst :: List<T>
) -> List<T>:
  for L.fold_n(n from start, acc from [list:], elem from lst):
    if f(n, elem):
      link(elem, acc)
    else:
      acc
    end
  end.reverse()
end

fun option-from-either<A, B>(val :: E.Either<A, B>) -> Option<B>:
  cases (E.Either) val:
    | left(_) => none
    | right(v) => some(v)
  end
end
