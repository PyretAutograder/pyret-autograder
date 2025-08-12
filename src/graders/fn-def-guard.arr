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
  mk-def-guard,
  data DefGuardBlock,
  check-fun-defined as _check-fun-defined,
  fmt-fun-def as _fmt-fun-def
end

data DefGuardBlock:
  | parser-error(err :: CA.ParsePathErr) # this should've been caught by wf
  | fn-not-defined(name :: String, arity :: Number)
  | wrong-arity(name :: String, expected :: Number, actual :: Number)
end

fun check-fun-defined(
  path :: String,
  name :: String,
  arity :: Number
) -> Option<DefGuardBlock>:
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
) -> Option<DefGuardBlock>:
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

fun fmt-fun-def(reason :: DefGuardBlock) -> GB.ComboAggregate:
  student = cases (DefGuardBlock) reason:
    | parser-error(_) =>
      # assuming we depend on wf, wes should never see this case
      # so hopefully it's fine to have a bad error here
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

fun mk-def-guard(id :: Id, deps :: List<Id>, path :: String, fn-name :: String, arity :: Number):
  name = "Find function " + fn-name + " with " + num-to-string(arity) + " arguments"
  checker = lam(): check-fun-defined(path, fn-name, arity) end
  GB.mk-guard(id, deps, checker, name, fmt-fun-def)
end
