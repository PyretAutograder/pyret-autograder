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
import npm("pyret-lang", "../../src/arr/compiler/well-formed.arr") as WF
import npm("pyret-lang", "../../src/arr/compiler/compile-structs.arr") as CS
import npm("pyret-lang", "../../src/arr/compiler/ast-util.arr") as AU
import file("../core.arr") as C
import file("../grading.arr") as G
import file("../grading-builders.arr") as GB
import file("../common/ast.arr") as CA
import file("../common/markdown.arr") as MD
import ast as A
import lists as L

include either
include from C:
  type Id
end

provide:
  mk-const-def,
  data ConstDefGuardBlock,
  check-const-def as _check-const-def,
  fmt-const-def as _fmt-const-def
end

data ConstDefGuardBlock:
  | parser-error(err :: CA.ParsePathErr) # this should've been caught by wf
  | const-not-defined(name :: String)
end

fun check-const-def(
  path :: String,
  name :: String
) -> Option<ConstDefGuardBlock>:
  cases (Either) CA.parse-path(path):
    | left(err) => some(parser-error(err))
    | right(ast) =>
      ast-ended = AU.append-nothing-if-necessary(ast)
      cases (A.Program) ast-ended:
        | s-program(_, _, _, _, _, _, body) =>
          cases (A.Expr) body:
            | s-block(_, stmts) => find-def(stmts, name)
            | else => some(const-not-defined(name))
          end
      end
  end
end

fun bind-has-name(bind :: A.Bind, query :: String) -> Boolean:
  cases (A.Bind) bind:
    | s-bind(_, _, name, _) => 
      cases (A.Name) name:
        | s-name(_, shadow name) => name == query
        | else => false
      end
    | s-tuple-bind(_, fields, as-name) =>
      L.any(bind-has-name(_, query), fields) or (as-name == query)
  end
end

fun find-def(
  stmts :: List<A.Expr>,
  expected-name :: String
) -> Option<ConstDefGuardBlock>:
  cases (List) stmts:
    | empty => some(const-not-defined(expected-name))
    | link(st, rest) =>
      cases (A.Expr) st:
        | s-let(_, bind, _, _) =>
          if bind-has-name(bind, expected-name):
            none
          else:
            find-def(rest, expected-name)
          end
        | else => find-def(rest, expected-name)
      end
  end
end

fun fmt-const-def(reason :: ConstDefGuardBlock) -> GB.ComboAggregate:
  student = cases (ConstDefGuardBlock) reason:
    | parser-error(_) =>
      # should never see this case if depends on wf
      "Cannot find your constant because we cannot parse your file."
    | const-not-defined(name) =>
      "Cannot find a constant defined named `" + MD.escape-inline-code(name) +
      "`. Perhaps you mistyped the name."
     end ^ G.output-markdown
  staff = none
  {student; staff}
end

fun mk-const-def(id :: Id, deps :: List<Id>, path :: String, const-name :: String):
  name = "Defined constant `" + const-name + "`"
  checker = lam(): check-const-def(path, const-name) end
  GB.mk-guard(id, deps, checker, name, fmt-const-def)
end
