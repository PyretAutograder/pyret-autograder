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
provide:
  make-fun-splicer,
  shadow-visitor,
  make-fun-extractor,
  make-check-extractor,
  make-check-filter,
  make-program-appender,
  make-program-prepender,
  merge-impl-stmts
end

import ast as A
import string-dict as SD

fun make-fun-splicer(fun-to-splice):
  A.default-map-visitor.{
    is-top-level : true,
    method s-fun(self, l, name, params, args, ann, doc, body, _check-loc, _check, blocky):
      is-top-level = self.is-top-level
      shadow self = self.{ is-top-level: false }
      if (name == fun-to-splice.name) and is-top-level:
        A.s-fun(l, name, fun-to-splice.params, fun-to-splice.args, fun-to-splice.ann, fun-to-splice.doc, fun-to-splice.body, fun-to-splice._check-loc, self.option(_check), fun-to-splice.blocky)
      else:
        A.s-fun(l, name, params, args.map(_.visit(self)), ann.visit(self), doc, body.visit(self), _check-loc, self.option(_check), blocky)
      end
    end
  }
end

shadow-visitor = A.default-map-visitor.{
  method s-bind(self, l, shadows, name, ann):
    cases (A.Name) name:
      # TODO: remove this check once `shadow _` is allowed
      | s-underscore(_) => A.s-bind(l, shadows, name, ann)
      | else => A.s-bind(l, true, name, ann)
    end
  end
}

fun make-fun-extractor(target-name) block:
  var target = none
  A.default-map-visitor.{
    method get-target(self): target end,
    method s-fun(self, l, name, params, args, ann, doc, body, _check-loc, _check, blocky) block:
      visited = A.s-fun(l, name, params, args.map(_.visit(self)), ann.visit(self), doc, body.visit(self), _check-loc, self.option(_check), blocky)
      when target-name == name:
        target := some(visited)
      end
      visited
    end
  }
end

fun make-check-extractor(target-name :: String) block:
  var target = none
  A.default-map-visitor.{
    method get-target(self): target end,
    method s-check(self, l, name, body, keyword-check) block:
      visited = A.s-check(l, name, body.visit(self), keyword-check)
      when some(target-name) == name:
        target := some(visited)
      end
      visited
    end
  }
end

# pred :: (String -> Boolean)
# For s-fun nodes, pred is called with the function name (a String).
# For s-check nodes, pred is called with the inner name string when the check
# block is named; unnamed check blocks are always removed.
# Example: pred = lam(n): n == "foo" end
#   - keeps s-fun named "foo" (with its where block)
#   - keeps standalone named check blocks "foo"
#   - removes all other check blocks/where blocks
# Example: pred = lam(_): false end
#   - removes ALL check blocks (both s-fun where blocks and s-check blocks)
fun make-check-filter(pred :: (String -> Boolean)):
  A.default-map-visitor.{
    method s-check(self, l, name, body, keyword-check):
      # name :: Option<String>; unwrap and apply pred; unnamed blocks are removed
      keep = cases (Option) name:
        | some(n) => pred(n)
        | none => false
      end
      if keep:
        A.s-check(l, name, body.visit(self), keyword-check)
      else:
        A.s-id(l, A.s-name(l, "nothing"))
      end
    end,

    method s-fun(self, l, name, params, args, ann, doc, body, _check-loc, _check, blocky):
      if pred(name):
        A.s-fun(l, name, params, args, ann, doc, body, _check-loc, _check, blocky)
      else:
        A.s-fun(l, name, params, args, ann, doc, body, _check-loc, none, blocky)
      end
    end
  }
end

fun block-transformer(transformer :: (List<A.Expr> -> List<A.Expr>)):
  A.default-map-visitor.{
    method s-program(self, l, _use, _provide, provided-types, provides, imports, body) block:
      new-body = cases(A.Expr) body:
        | s-block(shadow l, stmts) => A.s-block(l, transformer(stmts))
        # TODO: is it ok to throw here? is this a true invariant?
        | else => raise("make-program-appender: found a non-s-block inside s-program")
      end
      A.s-program(l, self.option(_use), _provide.visit(self), provided-types.visit(self), provides.map(_.visit(self)), imports.map(_.visit(self)), new-body.visit(self))
    end
  }
end

fun make-program-appender(expr):
  block-transformer(_.append([list: expr]))
end

fun make-program-prepender(expr):
  block-transformer(link(expr, _))
end

# ---------------------------------------------------------------------------
# merge-impl-stmts: merge alt-impl statements into student statements.
#
# For each top-level named definition in alt-impl:
#   - If the name already exists in student → replace student's stmt with
#     alt-impl's stmt (stripping any top-level shadow flag).
#   - If the name is new → it is a helper; prepend it before student stmts.
# Unnamed stmts (check blocks, bare expressions) are kept from student as-is;
# unnamed stmts from alt-impl are ignored.
# ---------------------------------------------------------------------------

fun bind-name(bind :: A.Bind) -> Option<String>:
  cases (A.Bind) bind:
    | s-bind(_, _, name, _) =>
      cases (A.Name) name:
        | s-name(_, n) => some(n)
        | else => none
      end
  end
end

fun stmt-top-level-name(stmt :: A.Expr) -> Option<String>:
  cases (A.Expr) stmt:
    | s-fun(_, name, _, _, _, _, _, _, _, _, _) => some(name)
    | s-let(_, bind, _, _) => bind-name(bind)
    | s-rec(_, bind, _) => bind-name(bind)
    | s-var(_, bind, _) => bind-name(bind)
    | else => none
  end
end

# Strip the shadow flag from the top-level bind of an s-let or s-rec.
# Not needed for s-fun (no top-level shadow concept).
fun strip-top-level-shadow(stmt :: A.Expr) -> A.Expr:
  cases (A.Expr) stmt:
    | s-let(l, bind, val, kw) =>
      cases (A.Bind) bind:
        | s-bind(bl, _, name, ann) =>
          A.s-let(l, A.s-bind(bl, false, name, ann), val, kw)
      end
    | s-rec(l, bind, val) =>
      cases (A.Bind) bind:
        | s-bind(bl, _, name, ann) =>
          A.s-rec(l, A.s-bind(bl, false, name, ann), val)
      end
    | else => stmt
  end
end

fun merge-impl-stmts(
  student-stmts :: List<A.Expr>,
  alt-impl-stmts :: List<A.Expr>
) -> List<A.Expr> block:
  # Build dict: name -> stmt for all named top-level stmts in alt-impl
  alt-impl-dict = SD.make-mutable-string-dict()
  for each(stmt from alt-impl-stmts):
    cases (Option) stmt-top-level-name(stmt):
      | some(n) => alt-impl-dict.set(n, stmt)
      | none => nothing
    end
  end

  # Collect all names defined at the top level of the student's program
  student-names = SD.make-mutable-string-dict()
  for each(stmt from student-stmts):
    cases (Option) stmt-top-level-name(stmt):
      | some(n) => student-names.set(n, true)
      | none => nothing
    end
  end

  # New stmts: named alt-impl stmts whose name does NOT appear in student,
  # preserved in their original order from alt-impl.
  new-stmts = for filter(stmt from alt-impl-stmts):
    cases (Option) stmt-top-level-name(stmt):
      | some(n) => not(student-names.has-key(n))
      | none => false
    end
  end

  # Merged student stmts: replace student stmts that have an alt-impl version.
  # When both student and alt-impl define a fun with the same name, transfer the
  # student's where-check block to the alt-impl's fun so student tests survive.
  merged-stmts = for map(stmt from student-stmts):
    cases (Option) stmt-top-level-name(stmt):
      | some(n) =>
        if alt-impl-dict.has-key(n):
          alt-stmt = strip-top-level-shadow(alt-impl-dict.get-value(n))
          cases (A.Expr) stmt:
            | s-fun(_, _, _, _, _, _, _, _, student-check, _) =>
              cases (A.Expr) alt-stmt:
                | s-fun(al, aname, aparams, aargs, aann, adoc, abody, ack-loc, _, ablocky) =>
                  A.s-fun(al, aname, aparams, aargs, aann, adoc, abody, ack-loc, student-check, ablocky)
                | else => alt-stmt
              end
            | else => alt-stmt
          end
        else:
          stmt
        end
      | none => stmt
    end
  end

  new-stmts + merged-stmts
end
