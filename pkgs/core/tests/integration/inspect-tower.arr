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

# based off https://course.ccs.neu.edu/cs2500accelf23/Homeworks/ps3b.html

import file("../meta/path-utils.arr") as P
include file("../meta/inspect-grade.arr")
include file("../../src/main.arr")
include file("../../src/tools/main.arr")
include file("../../src/utils/general.arr")
import lists as L

fun mk-examplar(fn, num, dep, path, constr, typ):
  # TODO: great example of why #11 is needed
  points = safe-divide(2, num, 0)
  L.build-list(
    lam(i):
      suff = num-to-string(i + 1)
      constr(
        fn + "-" + typ + "-" + suff, [list: dep], path, 
        P.example("tower-grading/" + fn + "/" + typ + "-" + suff + ".arr"),
        fn, points
      )
    end, 
    num
  )
end

fun mk-wheats(fn :: String, num :: Number, dep :: String, path :: String):
  mk-examplar(fn, num, dep, path, mk-wheat, "wheat")
end

fun mk-chaffs(fn :: String, num :: Number, dep :: String, path :: String):
  mk-examplar(fn, num, dep, path, mk-chaff, "chaff")
end

fun test-design-recipe-for(
  opts :: {
    fn :: String, arity :: Number,
    min-in :: Number, min-out :: Number,
    wheats :: Number, chaffs :: Number
  },
  deps :: List<String>,
  path :: String
):
  fn = opts.fn
  [list:
    mk-fn-def(fn + "-def", deps, path, fn, opts.arity),
    mk-self-test(fn + "-self-test", [list: fn + "-def"], path, fn, 1),
    mk-test-diversity(fn + "-diversity", [list: fn + "-def"], path, fn, opts.min-in, opts.min-out),
    mk-functional(
      fn + "-functional", [list: fn + "-def"], path, 
      P.example("tower-grading/functionality.arr"), fn + ": functionality", 
      4, some(fn))]
  + mk-wheats(fn, opts.wheats, fn + "-diversity", path)
  + mk-chaffs(fn, opts.chaffs, fn + "-diversity", path)
end

fun build-graders(path :: String):
  [list:
    mk-well-formed("wf", [list:], path),
    mk-training-wheels("tw", [list: "wf"], path, false)]
  + test-design-recipe-for({
      fn: "num-rooms", arity: 1,
      min-in: 4, min-out: 3,
      wheats: 2, chaffs: 3
    }, [list: "tw"], path)
  + test-design-recipe-for({
      fn: "max-rooms", arity: 1,
      min-in: 4, min-out: 3,
      wheats: 2, chaffs: 3
    }, [list: "tw"], path)
  + test-design-recipe-for({
      fn: "first-floor", arity: 1,
      min-in: 1, min-out: 1,
      wheats: 2, chaffs: 4
    }, [list: "tw"], path)
  + test-design-recipe-for({
      fn: "is-unbalanced", arity: 1,
      min-in: 3, min-out: 2,
      wheats: 2, chaffs: 4
    }, [list: "tw"], path)
end

graders = build-graders(P.example("tower.arr"))

# FIXME: nested modules not working
# debugging.wait-for-debugger()
result = inspect-grade(graders, false, false)

check "aggregate-to-flat smoke":
  grading-helpers.aggregate-to-flat(result.aggregated) does-not-raise
end


