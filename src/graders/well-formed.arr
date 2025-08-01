import npm("pyret-lang", "../../src/arr/compiler/well-formed.arr") as WF
import npm("pyret-lang", "../../src/arr/compiler/compile-structs.arr") as CS
import npm("pyret-lang", "../../src/arr/compiler/ast-util.arr") as AU
import file("../common/ast.arr") as CA
import file("../grading-builders.arr") as GB
import file("../grading.arr") as G
import file("../core.arr") as C
import error as ERR
import file as F
include either
include from C: type Id end

provide:
  mk-well-formed,
  data WFBlock,
  check-well-formed as _check-well-formed,
  fmt-well-formed as _fmt-well-formed
end

data WFBlock:
  | invalid-filepath(filepath :: String)
  | cannot-parse(x :: Any)
  | not-wf(x :: Any)
end

fun check-well-formed(filepath :: String) -> Option<WFBlock>:
  if not(F.file-exists(filepath)):
    some(invalid-filepath(filepath))
  else:
    maybe-parsed = CA.parse-path(filepath)
    cases (Either) maybe-parsed:
      | left(err) => some(cannot-parse(err.exn))
      | right(ast) =>
        ast-ended = AU.append-nothing-if-necessary(ast)
        wf-check-res = WF.check-well-formed(ast-ended)
        cases (CS.CompileResult) wf-check-res:
          | err(problems) => some(problems)
          | ok(_) => none # TODO: also check for other compilation error
        end
    end
  end
end

fun fmt-well-formed(reason :: WFBlock) -> GB.ComboAggregate:
  # TODO: finish formatting
  student = cases (WFBlock) reason block:
    | invalid-filepath(filepath) => "Cannot find a file to grade at " + filepath
    | connot-parse(_) => "TODO: cannot parse"
    | not-wf(_) => "TODO: not wf"
  end ^ G.output-text
  staff = none
  {student; staff}
end

fun mk-well-formed(id :: Id, deps :: List<Id>, filepath :: String):
  name = "Wellformed Check"
  checker = lam(): check-well-formed(filepath) end
  GB.mk-guard(id, deps, checker, name, fmt-well-formed)
end


