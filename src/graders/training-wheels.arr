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
  mk-training-wheels,
  find-mutation as _find-mutation,
  fmt-training-wheels as _fmt-training-wheels
end

data TrainingWheelsBlock:
  | parser-error(err :: CA.ParsePathErr)
  | found-mutation(vars :: List<SL.Srcloc>, refs :: List<SL.Srcloc>, tl-only :: Boolean)
end

fun find-mutation(path :: String, top-level-only :: Boolean) -> Option<TrainingWheelsBlock>:
  # TODO: better heuristics for finding refs, and maybe allow non-top-level ones
  cases (Either) CA.parse-path(path):
  | left(err) => some(parser-error(err))
  | right(ast) =>
    cases (A.Program) ast:
    | s-program(_, _, _, _, _, _, e) =>
      vars = if top-level-only: top-level-vars(e)
      else: all-vars(e)
      end
      refs = all-refs(e)
      if (vars.length() == 0) and (refs.length() == 0):
        none
      else:
        some(found-mutation(vars, refs, top-level-only))
      end
    end
  end
end

fun top-level-vars(e :: A.Expr) -> List<SL.Srcloc>:
  fun filter-map<T, U>(pred :: (T -> Option<U>), l :: List<T>) -> List<U>:
    cases (List) l:
    | empty => empty
    | link(f, r) =>
      cases (Option) pred(f):
      | none => filter-map(pred, r)
      | some(v) => link(v, filter-map(pred, r))
      end
    end
  end

  cases (A.Expr) e:
  | s-block(_, stmts) =>
    filter-map(lam(st):
      cases (A.Expr) st:
      | s-var(l, _, _) => some(l)
      | else => none
      end
    end, stmts)
  | else => raise("top-level-vars: expects s-block of whole program")
  end
end

fun all-vars(e :: A.Expr) -> List<SL.Srcloc> block:
  var found = [list:]
  visitor = A.default-iter-visitor.{
    method s-var(self, l, _, _) block:
      found := link(l, found)
      true
    end
  }
  e.visit(visitor)
  found.reverse()
end

fun all-refs(e :: A.Expr) -> List<SL.Srcloc> block:
  var found = [list:]
  visitor = A.default-iter-visitor.{
    method s-ref(self, l, _) block:
      found := link(l, found)
      true
    end,
    method s-variant-member(self, l, ty :: A.VariantMemberType, _) block:
      cases (A.VariantMemberType) ty:
      | s-mutable => found := link(l, found)
      | else => nothing
      end
      true
    end
  }
  e.visit(visitor)
  found.reverse()
end

fun fmt-training-wheels(reason :: TrainingWheelsBlock) -> GB.ComboAggregate:
  fun format-srcloc-list(l :: List<SL.Srcloc>) -> String:
    l.map(lam(x): "- " + x.format(true) end).join-str("\n")
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
    + (if tl-only:
      " Mutable variables are not allowed at the top-level of your programs. "
      else:
        " Mutable variables are not yet allowed in your programs. "
      end)
    + formatted-vars
    ref-message =
      "Referencess are a mutable feature that cannot be used at this time. "
      + formatted-refs
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

fun mk-training-wheels(id :: Id, deps :: List<Id>, path :: String, top-level-only :: Boolean):
  name = "Training wheels"
  checker = lam(): find-mutation(path, top-level-only) end
  GB.mk-guard(id, deps, checker, name, fmt-training-wheels)
end
