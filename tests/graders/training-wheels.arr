import file("../meta/path-utils.arr") as P
include file("../../src/graders/training-wheels.arr")
include srcloc

find-mutation = _find-mutation

fun only-lines(l :: List<Srcloc>) -> List<Srcloc>:
  l.map(lam(x):
    cases (Srcloc) x:
    | builtin(mod) => builtin(mod)
    | srcloc(_, sl, _, _, el, _, _) =>
        srcloc("", sl, 0, 0, el, 0, 0)
    end
  end)
end

fun portable(result :: Option<TrainingWheelsBlock>) -> Option<TrainingWheelsBlock>:
  doc: ```
  Strip machine-specific information from srclocs in a block. Removes volatile
  information like the absolute file path and column numbers which are harder to
  test against.
  ```
  cases (Option) result:
  | none => none
  | some(b) =>
    some(cases (TrainingWheelsBlock) b:
    | parser-error(e) => parser-error(e)
    | found-mutation(vars, refs, tl) =>
      found-mutation(only-lines(vars), only-lines(refs), tl)
    end)
  end
end

check "training-wheels: flags mutation":
  portable(find-mutation(P.file("top-level-mutation.arr"), false)) is
    some(found-mutation(
        [list: srcloc("", 1, 0, 0, 1, 0, 0), srcloc("", 4, 0, 0, 4, 0, 0)],
        [list:],
        false
    ))
  portable(find-mutation(P.file("top-level-mutation.arr"), true)) is
    some(found-mutation(
        [list: srcloc("", 1, 0, 0, 1, 0, 0)],
        [list:],
        true
    ))

  portable(find-mutation(P.file("inner-mutation.arr"), false)) is
    some(found-mutation(
        [list: srcloc("", 2, 0, 0, 2, 0, 0)],
        [list:],
        false
    ))
  portable(find-mutation(P.file("inner-mutation.arr"), true)) is none

  portable(find-mutation(P.file("use-ref.arr"), false)) is
    some(found-mutation([list: ], [list: srcloc("", 2, 0, 0, 2, 0, 0)], false))
  portable(find-mutation(P.file("use-ref.arr"), true)) is
    some(found-mutation([list: ], [list: srcloc("", 2, 0, 0, 2, 0, 0)], true))

  portable(find-mutation(P.file("nested-fun-var.arr"), true)) is none
  portable(find-mutation(P.file("nested-fun-var.arr"), false)) is
    some(found-mutation([list: srcloc("", 3, 0, 0, 3, 0, 0)], [list:], false))
end
