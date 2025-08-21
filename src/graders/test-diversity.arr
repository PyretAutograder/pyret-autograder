import npm("pyret-lang", "../../src/arr/compiler/compile-structs.arr") as CS
import npm("pyret-lang", "../../src/arr/compiler/ast-util.arr") as AU
import npm("pyret-lang", "../../src/arr/compiler/gensym.arr") as GS

import file("../core.arr") as C
import file("../grading.arr") as G
import file("../grading-builders.arr") as GB
import file("../common/ast.arr") as CA
import file("../common/markdown.arr") as MD
import file("../common/visitors.arr") as V
import file("../common/repl-runner.arr") as R

import ast as A
import srcloc as SL
import lists as L
import json as J

include either
include from C:
  type Id
end

provide:
  data DiversityGuardBlock,
  check-test-diversity as _check-test-diversity
end

# TODO: handle exceptions in student code

dummy-file-name = "autograder"
var next-line = 0

fun dummy-loc() -> SL.Srcloc block:
  next-line := next-line + 1
  SL.srcloc(dummy-file-name, next-line, 0, 0, next-line, 0, 0)
end

data DiversityGuardBlock:
  | parser-error(err :: CA.ParsePathErr)
  | fn-not-defined(name :: String)
  | run-error(err :: R.RunChecksErr)
  | invalid-result(unexpected :: J.JSON)
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
    | right(instrumented) =>
      cases (Either) R.run(instrumented) block:
      | left(err) => some(run-error(err))
      | right({j; _}) =>
        parse-check-results(
          j,
          fn,
          "check-" + fn + "-diversity-inputs",
          "check-" + fn + "-diversity-outputs"
        )
      end
    end
  end
end

fun parse-check-results(raw :: J.JSON, fn :: String, inputs-name :: String, outputs-name :: String) -> Option<DiversityGuardBlock>:
  bad = some(invalid-result(raw))
  var seen-inputs = false
  var seen-outputs = false

  fun parse-blocks-result(b :: List<J.JSON>) -> Option<DiversityGuardBlock>:
    cases (List) b:
    | empty =>
      if seen-inputs and seen-outputs:
        none
      else:
        bad
      end
    | link(single-block, rest) =>
      recursive = lam(): parse-blocks-result(rest) end
      cases (J.JSON) single-block:
      | j-obj(dict) =>
        cases (Option) dict.get("name"):
        | some(name) =>
          cases (J.JSON) name:
          | j-str(name-str) =>
            cases (Option) dict.get("total"):
            | some(total-opt) =>
              cases (J.JSON) total-opt:
              | j-num(total) =>
                cases (Option) dict.get("passed"):
                | some(passed-opt) =>
                  cases (J.JSON) passed-opt:
                  | j-num(passed) =>
                    success = total == passed
                    # intentionally prioritizing inputs because our output info
                    # is even less useful if there are too few inputs
                    if name-str == inputs-name:
                      if success block:
                        seen-inputs := true
                        recursive()
                      # TODO: make these not 0
                      else: some(too-few-inputs(fn, 0, 0))
                      end
                    else if name-str == outputs-name:
                      if success block:
                        seen-outputs := true
                        recursive()
                      else: some(too-few-outputs(fn, 0, 0))
                      end
                    else: recursive()
                    end
                  | else => bad
                  end
                | else => bad
                end
              | else => bad
              end
            | else => bad
            end
          | else => bad
          end
        | else => recursive()
        end
      | else => bad
      end
    end
  end

  cases (J.JSON) raw:
  | j-obj(dict) =>
    cases (Option) dict.get(dummy-file-name):
    | some(autograder-results) =>
      cases (J.JSON) autograder-results:
      | j-arr(blocks) => parse-blocks-result(blocks)
      | else => bad
      end
    end
  | else => bad
  end
end

fun instrument(
  student :: A.Program,
  fn :: String,
  min-in :: Number,
  min-out :: Number
) -> Either<DiversityGuardBlock, A.Program>:
  ast-ended = AU.append-nothing-if-necessary(student)
  empty-list-set-stx = lam():
    # `[Autograder-Sets.list-set:]`
    A.s-construct(
      dummy-loc(),
      A.s-construct-normal,
      A.s-dot(dummy-loc(), A.s-id(dummy-loc(), A.s-name(dummy-loc(), "Autograder-Sets")), "list-set"),
      [list:]
    )
  end
  state = [list:
    # `var [fn]-diversity-inputs = [Autograder-Sets.list-set:]`
    A.s-var(
      dummy-loc(),
      A.s-bind(dummy-loc(), false, A.s-name(dummy-loc(), fn + "-diversity-inputs"), A.a-blank),
      empty-list-set-stx()
    ),
    # `var [fn]-diversity-outputs = [Autograder-Sets.list-set:]`
    A.s-var(
      dummy-loc(),
      A.s-bind(dummy-loc(), false, A.s-name(dummy-loc(), fn + "-diversity-outputs"), A.a-blank),
      empty-list-set-stx()
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
    | s-program(l, uses, p, ptypes, provides, imports, body) =>
      # `import sets as Autograder-Sets`
      new-imports = link(
        A.s-import(
          dummy-loc(),
          A.s-const-import(dummy-loc(), "sets"),
          A.s-name(dummy-loc(), "Autograder-Sets")
        ),
        imports
      )
      final-program = A.s-program(l, uses, p, ptypes, provides, new-imports, body)
      right(final-program)
    end
  | none => left(fn-not-defined(fn))
  end
end

fun wrap-function(
  student :: A.Program,
  fn :: String
) -> Option<A.Program> block:
  extractor = V.make-fun-extractor(fn)
  student.visit(extractor)
  maybe-student-fn = extractor.get-target()
  cases (Option) maybe-student-fn:
  | none => none
  | some(student-fn) =>
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
            dummy-loc(),
            A.s-bind(dummy-loc(), false, A.s-name(dummy-loc(), "output"), A.a-blank),
            A.s-app(
              dummy-loc(),
              A.s-id(dummy-loc(),
              A.s-name(dummy-loc(), student-fn-name)),
              all-args-ids
            ),
            false
          ),
          # `[fn]-diversity-inputs := [fn]-diversity-inputs.add({[args]})`
          A.s-assign(
            dummy-loc(),
            A.s-name(dummy-loc(), inputs),
            A.s-app(
              dummy-loc(),
              A.s-dot(dummy-loc(), A.s-id(dummy-loc(), A.s-name(dummy-loc(), inputs)), "add"),
              [list: A.s-tuple(dummy-loc(), all-args-ids)]
            )
          ),
          # `[fn]-diversity-outputs := [fn]-diversity-outputs.add(output)`
          A.s-assign(
            dummy-loc(),
            A.s-name(dummy-loc(), outputs),
            A.s-app(
              dummy-loc(),
              A.s-dot(dummy-loc(), A.s-id(dummy-loc(), A.s-name(dummy-loc(), outputs)), "add"),
              [list: A.s-id(dummy-loc(), A.s-name(dummy-loc(), "output"))]
            )
          ),
          # `output`
          A.s-id(dummy-loc(), A.s-name(dummy-loc(), "output"))
        ]
      )
      new-fn = A.s-fun(l, fn, params, all-args, ann, "", new-body, check-loc, checks, true)
      replaced = student.visit(V.make-fun-splicer(new-fn))
      some(replaced)
    | else => none
    end
  end
end

fun make-size-check(set-name :: String, min :: Number) -> A.Expr:
  # check "check-[set]":
  #   [set].size() > [min] is true
  # end
  A.s-check(
    dummy-loc(),
    some("check-" + set-name),
    A.s-block(
      dummy-loc(),
      [list:
        A.s-check-test(
          dummy-loc(),
          A.s-op-is(dummy-loc()),
          none,
          A.s-op(
            dummy-loc(), dummy-loc(),
            "op>=",
            A.s-app(
              dummy-loc(),
              A.s-dot(dummy-loc(), A.s-id(dummy-loc(), A.s-name(dummy-loc(), set-name)), "size"),
              [list:]
            ),
            A.s-num(dummy-loc(), min)
          ),
          some(A.s-bool(dummy-loc(), true)),
          none
        )
      ]
    ),
    true
  )
end

fun remove-underscore-args(name :: String, args :: List<A.Bind>) -> List<A.Bind>:
  fun convert-underscore(b :: A.Bind) -> A.Bind:
    cases (A.Bind) b:
    | s-bind(l, shadows, id, ann) =>
      new-id = cases (A.Name) id:
      | s-underscore(shadow l) => A.s-name(l, GS.make-name(name + "-underscore-"))
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
      A.s-id(dummy-loc(), id)
    | s-tuple-bind(l, fields, as-name) =>
      # TODO: figure out the `as-name` as its own thing
      # does this even matter? the wrapper code should not care at all
      # and there are no changes to the student function's argument bindings
      A.s-tuple(dummy-loc(), args-to-ids(fields))
    end
  end
end
