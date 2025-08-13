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
provide *
provide-types *

import json as J
import either as E
import option as O
import lists as L

data PJSON:
  | mk(v :: Option<J.JSON>, ops :: List<E.Either<String>>) with:
    method chain(self, op, f):
      cases(Option) self.v:
        | none => mk(none, link(E.left(op + " on no value"), self.ops))
        | some(j) => f(j)
      end
    end,
    method get(self, key :: String):
      op = "get(" + key + ")"
      self.chain(op, lam(j):
        cases(J.JSON) j:
          | j-obj(d) =>
            cases(Option) d.get(key):
              | none => mk(none, link(E.left(op + " missing, keys are " + (d.keys() ^ to-repr)), self.ops))
              | some(val) => mk(some(val), link(E.right(op), self.ops))
            end
          | else => mk(none, link(E.left(op + " not an object"), self.ops))
        end
      end)
    end,
    method find-match(self, key :: String, val :: String):
      op = "find-match(" + key + " = " + val + ")"
      lam(j):
        cases(J.JSON) j:
          | j-arr(l) =>
            maybe-found = L.find(lam(o):
              cases(J.JSON) o:
                | j-obj(d) => d.get(key) == some(J.j-str(val))
                | else => false
              end
            end, l)
            cases(Option) maybe-found:
              | none =>
                summaries = torepr(l.map(lam(o): cases(J.JSON) o:
                    | j-obj(d) => d.keys()
                    | else => "nonobj"
                  end
                end))
                mk(none,
                  link(E.left(op + " matches nothing against object summaries: " + summaries),
                  self.ops))
              | some(v) => mk(some(v), link(E.right(op), self.ops))
            end
          | else => mk(none, link(E.left(op + " not an array"), self.ops))
        end
      end
      ^ self.chain(op, _)
    end,
    method n(self):
      cases(Option) self.v:
        | none => E.left(self.ops)
        | some(j) =>
          cases(J.JSON) j:
            | j-num(num) => E.right(num)
            | else => E.left(link("n()", self.ops))
          end
      end
    end
end

fun pson(j :: J.JSON):
  mk(some(j), empty)
end
