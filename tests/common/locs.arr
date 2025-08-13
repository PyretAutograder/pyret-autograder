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
import srcloc as SL
import file("../meta/path-utils.arr") as P
include file("../../src/common/locs.arr")

check:
  sl1 = SL.srcloc(P.file("unparsable.arr"), 3, 1, 13, 3, 1, 13)
  src-available(sl1) is true
  extract-srcloc(sl1) is {""; ""; ""}

  sl2 = SL.srcloc(P.file("unparsable.arr"), 1, 5, -1, 1, 7, -1)
  src-available(sl2) is true
  extract-srcloc(sl2) is {"fun "; "foo"; "():"}

  sl3 = SL.srcloc(P.file("check.arr"), 5, 1, -1, 8, 3, -1)
  src-available(sl3) is true
  extract-srcloc(sl3) is {
    "";
    'check "check name":\n  1 is 1\n  foo(13) is 16\nend';
    ""}

  sl4 = SL.srcloc(P.file("cases.arr"), 8, 10, -1, 12, 3, -1)
  src-available(sl4) is true
  extract-srcloc(sl4) is {
    "can-go = ";
    'cases(TrafficLight) red:\n' +
      '  | red => "no"\n  | yellow => "maybe"\n  | green => "yes"\n' +
      'end';
    ' <> "no"'}

  sl5 = SL.srcloc(P.file("incomplete.arr"), 1, 35, -1, 2, 5, -1)
  src-available(sl5) is true
  extract-srcloc(sl5) is {
    "filtered = [list: 1, 2, 3].filter(";
    "lam(x):\n  end";
    ")"
  }
end

