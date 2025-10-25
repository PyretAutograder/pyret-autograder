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

include either
include from C:
  type Id
end

provide:
  mk-fn-def,
  data FnDefGuardBlock,
  check-fn-defined as _check-fn-defined,
  fmt-fn-def as _fmt-fn-def
end

data FnDefGuardBlock:
  | parser-error(err :: CA.ParsePathErr) # this should've been caught by wf
  | fn-not-defined(name :: String, arity :: Number)
  | wrong-arity(name :: String, expected :: Number, actual :: Number)
end

fun check-fn-defined(
  path :: String,
  name :: String,
  arity :: Number
) -> Option<FnDefGuardBlock>:
  cases (Either) CA.parse-path(path):
    | left(err) => some(parser-error(err))
    | right(ast) =>
      ast-ended = AU.append-nothing-if-necessary(ast)
      cases (A.Program) ast-ended:
        | s-program(_, _, _, _, _, _, body) =>
          cases (A.Expr) body:
            | s-block(_, stmts) => find-def(stmts, name, arity)
            | else => some(fn-not-defined(name, arity))
          end
      end
  end
end

fun find-def(
  stmts :: List<A.Expr>,
  expected-name :: String,
  expected-arity :: Number
) -> Option<FnDefGuardBlock>:
  cases (List) stmts:
    | empty => some(fn-not-defined(expected-name, expected-arity))
    | link(st, rest) =>
      cases (A.Expr) st:
        | s-fun(_, actual-name, _, args, _, _, _, _, _, _) =>
          if actual-name == expected-name:
            actual-arity = args.length()
            if actual-arity == expected-arity:
              none
            else:
              some(wrong-arity(expected-name, expected-arity, actual-arity))
            end
          else:
            find-def(rest, expected-name, expected-arity)
          end
        | else => find-def(rest, expected-name, expected-arity)
      end
  end
end

fun fmt-fn-def(reason :: FnDefGuardBlock) -> GB.ComboAggregate:
  student = cases (FnDefGuardBlock) reason:
    | parser-error(_) =>
      # should never see this case if depends on wf
      "Cannot find your function definition because we cannot parse your file."
    | fn-not-defined(name, arity) =>
      "Cannot find a function definiton named " + MD.escape-inline-code(name) +
      ". We expect a function " + MD.escape-inline-code(name) + " taking " +
      num-to-string(arity) + " arguments. Perhaps you mistyped the function name."
    | wrong-arity(name, expected, actual) =>
      "The definition for function " + MD.escape-inline-code(name) +
      " should have " + num-to-string(expected) + " arguments, but seems to have " +
      num-to-string(actual) + " arguments instead. Make sure your function is " +
      "defined correctly."
  end ^ G.output-markdown
  staff = none
  {student; staff}
end

fun mk-fn-def(id :: Id, deps :: List<Id>, path :: String, fn-name :: String, arity :: Number):
  name = "Find function " + fn-name + " with " + num-to-string(arity) + " arguments"
  checker = lam(): check-fn-defined(path, fn-name, arity) end
  GB.mk-guard(id, deps, checker, name, fmt-fn-def)
end
