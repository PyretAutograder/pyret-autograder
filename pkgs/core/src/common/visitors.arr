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
  nothing-stripper,
  top-level-checks
end

import ast as A

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

fun make-check-filter(pred :: (String -> Boolean)):
  A.default-map-visitor.{
    method s-check(self, l, name, body, keyword-check):
      if pred(name):
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

fun body-stmts(body :: A.Expr) -> List<A.Expr>:
  cases(A.Expr) body:
    | s-block(_, stmts) => stmts
    # TODO: is it ok to throw here? is this a true invariant?
    | else => raise("body-stmts: found a non-s-block inside s-program")
  end
end

fun block-transformer(transformer :: (List<A.Expr> -> List<A.Expr>)):
  A.default-map-visitor.{
    method s-program(self, l, _use, _provide, provided-types, provides, imports, body) block:
      new-body = A.s-block(body.l, transformer(body-stmts(body)))
      A.s-program(l, self.option(_use), _provide.visit(self), provided-types.visit(self), provides.map(_.visit(self)), imports.map(_.visit(self)), new-body.visit(self))
    end
  }
end

fun make-program-appender(exprs :: List<A.Expr>):
  block-transformer(_.append(exprs))
end

fun make-program-prepender(exprs :: List<A.Expr>):
  block-transformer(exprs.append(_))
end

fun top-level-checks(stx :: A.Program) -> List<A.Expr>:
  body-stmts(stx.block).filter(A.is-s-check)
end

fun is-nothing-stmt(stmt :: A.Expr) -> Boolean:
  cases (A.Expr) stmt:
    | s-id(_, name) =>
      cases (A.Name) name:
        | s-name(_, str) => str == "nothing"
        | else => false
      end
    | else => false
  end
end

fun drop-nothing-stmts(stmts :: List<A.Expr>) -> List<A.Expr>:
  kept = stmts.filter(lam(stmt): not(is-nothing-stmt(stmt)) end)
  if is-empty(kept): stmts else: kept end
end

# slight hack, can strip top-level student stmts too, but should be fine
nothing-stripper = block-transformer(drop-nothing-stmts)
