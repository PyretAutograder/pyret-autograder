import file("../core.arr") as C
import file("../grading.arr") as G
import file("../grading-builders.arr") as GB
import file("../common/ast.arr") as CA
import file("../common/markdown.arr") as MD
import file("../common/visitors.arr") as V
import file("../common/repl-runner.arr") as R

import ast as A
import srcloc as SL

include either
include from C:
  type Id
end

provide:
  data TrainingWheelsBlock,
  mk-training-wheels-guard,
  find-mutation as _find-mutation,
  fmt-training-wheels as _fmt-training-wheels
end

data TrainingWheelsBlock:
  | parser-error(err :: CA.ParsePathErr)
  | found-mutation(vars :: List<SL.Srcloc>, refs :: List<SL.Srcloc>, tl-only :: Boolean)
end

fun find-mutation(path :: String, top-level-only :: Boolean) -> Option<TrainingWheelsBlock>:
  var found-vars = [list:]
  var found-refs = [list:]
  var flag-vars = true
  cases (Either) CA.parse-path(path) block:
  | left(err) => some(parser-error(err))
  | right(ast) =>
    visitor = A.default-iter-visitor.{
      method s-var(self, l :: SL.Srcloc, _, _) block:
        found-vars := if flag-vars: link(l, found-vars)
        else: found-vars
        end
        true
      end,
      method s-ref(self, l, _) block:
        found-refs := link(l, found-refs)
        true
      end,
      method s-variant-member(self, l, ty :: A.VariantMemberType, _) block:
        cases (A.VariantMemberType) ty:
        | s-mutable => found-refs := link(l, found-refs)
        | else => nothing
        end
        true
      end,
      method s-fun(self, l, name, params, args, ann, doc, body, check-loc, checks, blocky):
        if top-level-only block: true
        else:
          flag-vars := not(top-level-only)
          out = params.all(_.visit(self))
            and args.all(_.visit(self))
            and ann.visit(self)
            and body.visit(self)
            and self.option(checks)
          flag-vars := true
          out
        end
      end
    }
    ast.visit(visitor)
    if (found-vars.length() == 0) and (found-refs.length() == 0):
      none
    else:
      # to get top-level first
      some(found-mutation(found-vars.reverse(), found-refs.reverse(), top-level-only))
    end
  end
end

fun fmt-training-wheels(reason :: TrainingWheelsBlock) -> GB.ComboAggregate:
  fun format-srcloc-list(l :: List<SL.Srcloc>) -> String:
    l.map("- " + _.format()).join-str("\n")
  end
  student = cases (TrainingWheelsBlock) reason:
  | parser-error(_) =>
    "Cannot find your function definition because we cannot parse your file."
  | found-mutation(vars, refs, tl-only) =>
    formatted-vars =
      "Found mutable variables at:\n" + format-srcloc-list(vars)
    formatted-refs =
      "Found references used at:\n" + format-srcloc-list(refs)
    var-message =
      "We found uses of mutation in your program that are not allowed."
    + if tl-only:
      " Mutable variables are not allowed at the top-level of your programs. "
    else:
      " Mutable variables are not yet allowed in your programs. "
    end
    + formatted-vars
    ref-message =
      "Referencess are not allowed in this course. " + formatted-refs
    if vars.length() > 0: var-message
    else: ""
    end
    + if refs.length() > 0: "\n" + ref-message
      else: ""
      end
  end ^ G.output-markdown
  staff = none
  {student; staff}
end

fun mk-training-wheels-guard(id :: Id, deps :: List<Id>, path :: String, top-level-only :: Boolean):
  name = "Training wheels"
  checker = lam(): find-mutation(path, top-level-only) end
  GB.mk-guard(id, deps, checker, name, fmt-training-wheels)
end
