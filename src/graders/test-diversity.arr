import npm("pyret-lang", "../../src/arr/compiler/compile-structs.arr") as CS
import npm("pyret-lang", "../../src/arr/compiler/ast-util.arr") as AU

import file("../core.arr") as C
import file("../grading.arr") as G
import file("../grading-builders.arr") as GB
import file("../common/ast.arr") as CA
import file("../common/markdown.arr") as MD
import file("../common/visitors.arr") as V

import ast as A
import srcloc as SL
import lists as L
import gensym as G

include either
include from C:
  type Id
end

# TODO: handle exceptions in student code

dummy-loc = SL.builtin("test-diversity")

data DiversityGuardBlock:
  | parser-error(err ::CA.ParsePathErr)
  | fn-not-defined(name :: String)
  | too-few-inputs(name :: String, expected :: Number, actual :: Number)
  | too-few-outputs(name :: String, expected :: Number, actual :: Number)
end

fun check-test-diversity(
  path :: String,
  fn :: String,
  min-in :: Number,
  min-out :: Number
) -> Option<DiversityGuardBlock>:
  cases (Either) CA.parse-path(path):
  | left(err) => some(parser-error(err))
  | right(ast) =>
    cases (Either) instrument(ast, fn, min-in, min-out):
    | left(err) => some(err)
    | right(instrumented) => none
    end
  end
end

fun instrument(
  student ::A.Program,
  fn :: String,
  min-in :: Number,
  min-out :: Number
) -> Either<DiversityGuardBlock, A.Program>:
  ast-ended = AU.append-nothing-if-necessary(student)
  empty-list-set = lam():
    # `[Autograder-Sets.list-set:]`
    A.s-construct(
      dummy-loc,
      A.s-construct-normal,
      A.s-dot(dummy-loc, A.s-id(dummy-loc, A.s-name("Autograder-Sets")), "list-set"),
      [list:]
    )
  end
  state = [list:
    # `var [fn]-diversity-inputs = [Autograder-Sets.list-set:]`
    A.s-var(
      dummy-loc,
      A.s-bind(dummy-loc, false, A.s-name(dummy-loc, fn + "-diversity-inputs"), A.a-blank),
      empty-list-set()
    ),
    # `var [fn]-diversity-outputs = [Autograder-Sets.list-set:]`
    A.s-var(
      dummy-loc,
      A.s-bind(dummy-loc, false, A.s-name(dummy-loc, fn + "-diversity-outputs"), A.a-blank),
      empty-list-set()
    )
  ]
  state-added = ast-ended.visit(V.make-program-prepender(state))
  cases (Option) wrap-function(state-added, fn):
  | some(wrapped) =>
    checks = [list:
      make-size-check(fn + "-diversity-inputs", min-in),
      make-size-check(fn + "-diversity-outputs", min-out)
    ]
    with-checks = for fold(acc from wrapped, c from checks):
      acc.visit(V.make-program-appender(c))
    end
    cases (A.Program) with-checks:
    | s-program(l, use, p, ptypes, provides, imports, body) =>
      # `import sets as Autograder-Sets`
      new-imports = link(
        A.s-import(
          dummy-loc,
          A.s-const-import(dummy-loc, "builtin://sets"),
          A.s-name(dummy-loc, "Autograder-Sets")
        ),
        imports
      )
      final-program = A.s-program(l, use, p, ptypes, provides, new-imports, body)
      right(final-program)
    end
  | none => left(fn-not-defined(fn))
  end
end

fun make-size-check(set :: String, min :: Number) -> A.Expr:
  # check "check-[set]":
  #   [set].size() > [min] is true
  # end
  A.s-check(
    dummy-loc,
    some("check-" + set),
    A.s-block(
      dummy-loc,
      [list:
        A.s-check-test(
          dummy-loc,
          A.s-op-is(dummy-loc),
          none,
          A.s-op(
            dummy-loc, dummy-loc,
            "op>=",
            A.s-app(
              dummy-loc,
              A.s-dot(dummy-loc, A.s-id(dummy-loc, A.s-name(dummy-loc, set)), "size"),
              [list:]
            ),
            A.s-num(dummy-loc, min)
          ),
          some(A.s-bool(dummy-loc, true)),
          none
        )
      ]
    )
    true
  )
end

fun wrap-function(
  student :: A.Program,
  fn :: String,
) -> Option<A.Program>:
  student-fn = student.visit(V.make-fun-extractor(fn))
  cases (A.Expr) student-fn:
  | s-fun(l, name, params, args, ann, doc, body, check-loc, checks, blocky) =>
    all-args = remove-underscore-args(fn, args)
    all-args-ids = args-to-ids(all-args)
    student-fn-name = "student-" + fn
    inner = A.s-fun(l, student-fn-name, params, args, ann, doc, body, none, none, blocky)
    shadow inner = inner.visit(V.shadow-visitor)

    inputs = fn + "-diversity-inputs"
    outputs = fn + "-diversity-outputs"

    new-body = A.s-block(
      l,
      [list:
        inner,
        # `output = student-[fn]([args])`
        A.s-let(
          dummy-loc,
          A.s-bind(dummy-loc, false, A.s-name(dummy-loc, "output"), A.a-blank),
          A.s-app(
            dummy-loc,
            A.s-id(dummy-loc,
            A.s-name(dummy-loc, student-fn-name)),
            all-args-ids
          )
        ),
        # `[fn]-diversity-inputs := [fn]-diversity-inputs.add({[args]})`
        A.s-assign(
          dummy-loc,
          A.s-name(dummy-loc, inputs),
          A.s-app(
            dummy-loc,
            A.s-dot(dummy-loc, A.s-id(dummy-loc, inputs), "add"),
            [list: A.s-tuple(dummy-loc, all-args-ids)]
          )
        ),
        # `[fn]-diversity-outputs := [fn]-diversity-outputs.add(output)`
        A.s-assign(
          dummy-loc,
          A.s-name(dummy-loc, outputs),
          A.s-app(
            dummy-loc,
            A.s-dot(dummy-loc, A.s-id(dummy-loc, outputs), "add"),
            [list: A.s-id(dummy-loc, A.s-name("output"))]
          )
        ),
        # `output`
        A.s-id(dummy-loc, A.s-name(dummy-loc, "output"))
      ]
    )
    new-fn = A.s-fun(l, fn, params, all-args, ann, "", new-body, check-loc, checks, true)
    replaced = student.visit(V.make-fun-splicer(new-fn))
    some(replaced)
  | else => none
  end
end

fun remove-underscore-args(name :: String, args :: List<A.Bind>) -> List<A.Bind>
  fun convert-underscore(b :: A.Bind) -> A.Bind:
    cases (A.Bind) b:
    | s-bind(l, shadows, id, ann) =>
      new-id = cases (A.Name) id:
      | s-underscore(l) => A.s-name(l, G.make-name(name + "-underscore-"))
      | else => id
      end
      A.s-bind(l, shadows, new-id, ann)
    | else => raise("unexpected tuple-bind")
    end
  end

  for map(b from args):
    cases (A.Bind) b:
    | s-bind(_, _, _, _) => convert-underscore(b)
    | s-tuple-bind(l, fields, as-name) =>
      A.s-tuple-bind(l, remove-underscore-args(fields), convert-underscore(as-name))
    end
  end
end

fun args-to-ids(args :: List<A.Bind>) -> List<A.Expr>:
  for map(b from args):
    cases (A.Bind) b:
    | s-bind(l, shadows, id, ann) =>
      # we know that there are no underscore binds, so we can just turn it into
      # an `s-id` freely
      A.s-id(dummy-loc, id)
    | s-tuple-bind(l, fields, as-name) =>
      # TODO: figure out the `as-name` as its own thing
      # does this even matter? the wrapper code should not care at all
      # and there are no changes to the student function's argument bindings
      A.s-tuple(dummy-loc, args-to-ids(fields))
    end
  end
end
