import npm("pyret-lang", "../../src/arr/compiler/well-formed.arr") as WF
import npm("pyret-lang", "../../src/arr/compiler/compile-structs.arr") as C
import npm("pyret-lang", "../../src/arr/compiler/ast-util.arr") as AU
import file("../common/ast.arr") as CA
import error as ERR

include either
include file("../grading.arr")
include file("../core.arr")

provide: 
  check-well-formed
end

fun check-well-formed(filepath :: String) -> GradingOutcome:
  maybe-parsed = CA.parse-path(filepath)
  cases (Either) maybe-parsed:
  # TODO: maybe just return string instead...
  | left(err) => block(cannot-parse(err.exn), grade-info(""))
  | right(ast) =>
    ast-ended = AU.append-nothing-if-necessary(ast)
    wf-check-res = WF.check-well-formed(ast-ended)
    cases (C.CompileResult) wf-check-res:
    | ok(_) => proceed(grade-info("")) # TODO: also check for other compilation error
    | err(problems) => 
      # TODO: deal with error reporting
      block(not-wf(to-repr(problems)), grade-info(""))
    end
  end
end

