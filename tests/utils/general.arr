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
include file("../../src/utils/general.arr")
import string-dict as SD

check "unique":
  unique([list:]) is [list:]
  unique([list: 1, 2, 3]) is [list: 1, 2, 3]
  unique([list: "a", "b", "c"]) is [list: "a", "b", "c"]
  unique([list: 1, 1, 2]) is [list: 1, 2]
end

check "has-duplicates":
  has-duplicates([list:]) is false
  has-duplicates([list: 1]) is false
  has-duplicates([list: 1, 1]) is true
end

check "list-to-stringdict":
  list-to-stringdict([list:]) is [SD.string-dict:]
  list-to-stringdict([list: {"key1"; 1}, {"key2"; 2}]) is [SD.string-dict: "key1", 1, "key2", 2]
end

check "safe-divide":
  safe-divide(1, 1, 0) is 1
  safe-divide(0, 0, 42) is 42
end

check "min":
  min(0, 0) is 0
  min(1, 2) is 1
  min(1, -1) is -1
end

check "max":
  max(0, 0) is 0
  max(1, 2) is 2
  max(1, -1) is 1
end

check "safe-inclusive-substring":
  substr = safe-inclusive-substring
  substr("01234", 1, 3) is "123"
  substr("", 0, 0) is ""
end

