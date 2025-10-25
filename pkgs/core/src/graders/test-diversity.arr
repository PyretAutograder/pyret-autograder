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
import file("../common/tmp-poc.arr") as AAAA # TODO: proper implementation

import ast as A
import srcloc as SL
import lists as L
import json as J
import string-dict as SD
import pprint as PP

include either
include from C:
  type Id
end

provide:
  mk-test-diversity,
  data DiversityGuardBlock,
  check-test-diversity as _check-test-diversity,
  fmt-test-diversity as _fmt-test-diversity
end

# file refuses to compile if this is not above all functions
# well-formed complains when different things are on the same line number
# this will (sporadically and inconsistently!) break if the student file is
# sufficiently large in line count
# FIXME: find a more permanent solution
var next-line = 1073741824

dummy-file-name = "autograder"
# surface pyret cannot use $ in identifiers, so we can be sure these aren't used
set-module-name = "$Autograder-Sets"
either-module-name = "$Autograder-Either"
at-least-util = "$autograder-at-least"

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
      cases (Either) R.run(instrumented):
      | left(err) => some(run-error(err))
      | right({j; _}) => parse-check-results(j, fn)
      end
    end
  end
end

fun fmt-test-diversity(reason :: DiversityGuardBlock) -> GB.ComboAggregate:
  student = cases (DiversityGuardBlock) reason:
  | parser-error(_) =>
    "Cannot find your function definition because we cannot parse your file."
  | fn-not-defined(name) =>
    "Cannot find a function named `" + MD.escape-inline-code(name)
    + "` in your code."
  | run-error(_) =>
    "We ran into an error trying to run your function and its tests."
  | invalid-result(_) =>
    "The autograder received an unexpected response running your tests. "
    + "Please report this bug to a staff member."
  | too-few-inputs(name, expected, actual) =>
    "Your tests for function `" + MD.escape-inline-code(name)
    + "` called it with " + num-to-string(actual) + " distinct sets of arguments. "
    + " A good test suite should make at least " + num-to-string(expected)
    + " distinct calls."
  | too-few-outputs(name, expected, actual) =>
     "Your tests for function `" + MD.escape-inline-code(name)
     + "` caused it to produce " + num-to-string(actual) + " different outputs."
     + " A good test suite should cause the function to produce at least "
     + num-to-string(expected) + " different outputs.\n"
     + "Note: This counts the _actual_ outputs your function returned, not "
     + "the expected outcomes in your tests. This may be flagging an incorrect "
     + "implementation _or_ an insufficient test suite."
  end ^ G.output-markdown
  staff = cases (DiversityGuardBlock) reason:
  | parser-error(_) => none
  | fn-not-defined(_)  => none
  | run-error(err) =>
    ("Got the following error when trying to run wrapped file:\n"
    + AAAA.tmp-fmt-runtime-err(err))
    ^ G.output-markdown
    ^ some
  | invalid-result(raw) =>
    json-string = raw.serialize()
    ("Got invalid JSON response when running wrapped file:\n```\n"
    + MD.escape-code-block(json-string)
    + "\n```")
    ^ G.output-markdown
    ^ some
  | too-few-inputs(name, expected, actual) => none
  | too-few-outputs(name, expected, actual) => none
  end
  {student; staff}
end

fun mk-test-diversity(
  id :: Id,
  deps :: List<Id>,
  path :: String,
  fn :: String,
  min-in :: Number,
  min-out :: Number
):
  name = "Test suite diversity for " + fn
  checker = lam(): check-test-diversity(path, fn, min-in, min-out) end
  GB.mk-guard(id, deps, checker, name, fmt-test-diversity)
end

# --- Name generation ---

fun dummy-loc() -> SL.Srcloc block:
  doc: ```
  The Pyret compiler assumes that all `check` blocks have real
  (i.e., not builtin) source locations. The well-formedness checker also rejects
  the file if multiple expressions in a `s-block` are on "the same line". So the
  easiest way around both of these is just to fake the line number every time.
  ```
  next-line := next-line + 1
  SL.srcloc(dummy-file-name, next-line, 0, 0, next-line, 0, 0)
end

fun input-set-name(fn :: String) -> String:
 "$autograder-" + fn + "-diversity-inputs"
end

fun output-set-name(fn :: String) -> String:
  "$autograder-" + fn + "-diversity-outputs"
end

fun input-check-name(fn :: String) -> String:
  "check-" + fn + "-diversity-inputs"
end

fun output-check-name(fn :: String) -> String:
  "check-" + fn + "-diversity-outputs"
end

# --- Check result parsing ---

data SeenCheck:
  | unseen
  | passed
  | failed(expected :: Number, actual :: Number)
end

fun parse-check-results(raw :: J.JSON, fn :: String) -> Option<DiversityGuardBlock>:
  bad = some(invalid-result(raw))
  var seen-inputs = unseen
  var seen-outputs = unseen

  fun parse-blocks-result(b :: List<J.JSON>) -> Option<DiversityGuardBlock>:
    cases (List) b:
    | empty =>
      cases (SeenCheck) seen-inputs:
      # intentionally prioritizing inputs because our output info
      # is even less useful if there are too few inputs
      | failed(expected, actual) => some(too-few-inputs(fn, expected, actual))
      | passed =>
        cases (SeenCheck) seen-outputs:
        | failed(expected, actual) => some(too-few-outputs(fn, expected, actual))
        | passed => none
        | unseen => bad
        end
      | unseen => bad
      end
    | link(single-block, rest) =>
      cases (J.JSON) single-block:
      | j-obj(dict) =>
        cases (J.JSON) dict.get-value("name"):
        | j-str(name) =>
          cases (J.JSON) dict.get-value("total"):
          | j-num(total) =>
            cases (J.JSON) dict.get-value("passed") block:
            | j-num(checks-passed) =>
              success = total == checks-passed
              new-state = update-check-state(success, dict)
              if name == input-check-name(fn):
                seen-inputs := new-state
              else if name == output-check-name(fn):
                seen-outputs := new-state
              else: nothing
              end
              parse-blocks-result(rest)
            | else => bad
            end
          | else => bad
          end
        | else => bad
        end
      | else => bad
      end
    end
  end

  fun parse-fail-result(block-result :: SD.StringDict<J.JSON>) -> Option<{Number; Number}>:
    cases (J.JSON) block-result.get-value("results"):
    | j-arr(results) =>
      cases (List) results:
      | link(single-check, rest) =>
        cases (J.JSON) single-check:
        | j-obj(check-dict) =>
          cases (J.JSON) check-dict.get-value("message"):
          | j-str(message) =>
            # FIXME (pyret-lang): need better/stable output format
            split = string-split-all(message, " ")
            reversed = split.reverse()
            if reversed.length() >= 2:
              expected-opt = reversed.get(0) ^ string-to-number
              actual-opt = reversed.get(1) ^ string-to-number
              cases (Option) expected-opt:
                | some(expected) =>
                  cases (Option) actual-opt:
                  | some(actual) =>
                    some({expected; actual})
                  | else => none
                  end
                | else => none
                end
            else:
              none
            end
          | else => none
          end
        | else => none
        end
      | else => none
      end
    | else => none
    end
  end

  fun update-check-state(
    success :: Boolean,
    dict :: SD.StringDict<J.JSON>
  ) -> SeenCheck:
    if success:
      passed
    else:
      cases (Option) parse-fail-result(dict):
      | some({expected; actual}) =>
        failed(expected, actual)
      | none => unseen
      end
    end
  end

  cases (J.JSON) raw:
  | j-obj(dict) =>
    cases (Option) dict.get(dummy-file-name):
    | some(autograder-results) =>
      cases (J.JSON) autograder-results:
      | j-arr(blocks) =>
        cases (Either) run-task(lam(): parse-blocks-result(blocks) end):
        | left(v) => v
        | right(_) => bad
        end
      | else => bad
      end
    end
  | else => bad
  end
end

# --- AST transformation ---

fun instrument(
  student :: A.Program,
  fn :: String,
  min-in :: Number,
  min-out :: Number
) -> Either<DiversityGuardBlock, A.Program>:
  ast-ended = AU.append-nothing-if-necessary(student)
  empty-list-set-stx = lam():
    # `[$Autograder-Sets.list-set:]`
    A.s-construct(
      dummy-loc(),
      A.s-construct-normal,
      A.s-dot(dummy-loc(), A.s-id(dummy-loc(), A.s-name(dummy-loc(), set-module-name)), "list-set"),
      [list:]
    )
  end
  state = [list:
    # `var $autograder-[fn]-diversity-inputs = [Autograder$Sets.list-set:]`
    A.s-var(
      dummy-loc(),
      A.s-bind(dummy-loc(), false, A.s-name(dummy-loc(), input-set-name(fn)), A.a-blank),
      empty-list-set-stx()
    ),
    # `var $autograder-[fn]-diversity-outputs = [Autograder$Sets.list-set:]`
    A.s-var(
      dummy-loc(),
      A.s-bind(dummy-loc(), false, A.s-name(dummy-loc(), output-set-name(fn)), A.a-blank),
      empty-list-set-stx()
    )
  ]
  state-added = add-all(ast-ended, state, V.make-program-prepender)
  utils = [list:
    # fun $autograder-at-least(a, b):
    #   a >= b
    # end
    A.s-fun(
      dummy-loc(),
      at-least-util,
      [list:],
      [list:
        A.s-bind(dummy-loc(), true, A.s-name(dummy-loc(), "a"), A.a-blank),
        A.s-bind(dummy-loc(), true, A.s-name(dummy-loc(), "b"), A.a-blank)
      ],
      A.a-blank,
      "",
      A.s-block(
        dummy-loc(),
        [list:
          A.s-op(
            dummy-loc(), dummy-loc(),
            "op>=",
            A.s-id(dummy-loc(), A.s-name(dummy-loc(), "a")),
            A.s-id(dummy-loc(), A.s-name(dummy-loc(), "b"))
          )
        ]
      ),
      none,
      none,
      false
    )
  ]
  utils-added = add-all(state-added, utils, V.make-program-prepender)
  cases (Option) wrap-function(utils-added, fn):
  | some(wrapped) =>
    checks = [list:
      make-size-check(input-set-name(fn), input-check-name(fn), min-in),
      make-size-check(output-set-name(fn), output-check-name(fn), min-out)
    ]
    # TODO: this should remove all irrelevant code. see #16
    student-checks-removed = wrapped.visit(V.make-check-filter(_ == fn))
    with-checks = add-all(student-checks-removed, checks, V.make-program-appender)
    cases (A.Program) with-checks:
    | s-program(l, uses, p, ptypes, provides, imports, body) =>
      new-imports = link(
        # `import sets as $Autograder-Sets`
        A.s-import(
          dummy-loc(),
          A.s-const-import(dummy-loc(), "sets"),
          A.s-name(dummy-loc(), set-module-name)
        ),
        link(
          # `import either as $Autograder-Either`
          A.s-import(
            dummy-loc(),
            A.s-const-import(dummy-loc(), "either"),
            A.s-name(dummy-loc(), either-module-name)
          ),
          imports
        )
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
  doc: ```
  Given a student program that contains this function definition
  (when `fn` is "foo"):
    fun foo(args):
      ...
    where:
      ...
    end
  gets wrapped into:
    fun foo(args):
      # underscore arguments are replaced with fresh names so we can refer to
      # them in the later call and set addition
      fun $autograder-student-foo(shadow args):
        ...
      end
      output = cases ($Autograder-Either.Either)
        run-task(lam(): $autograder-student-foo(args) end):
      | left(v) => left(v)
      | right(exn) => right(exn-unwrap(exn))
      end
      # {args} denotes that we put all of the arguments in a tuple
      $autograder-foo-diversity-inputs :=
        $autograder-foo-diversity-inputs.add({args})
      $autograder-foo-diversity-outputs :=
        $autograder-foo-diversity-outputs.add(output)
      output
    where:
      ...
    end
  ```
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
      student-fn-name = "$autograder-student-" + fn
      new-inner-body = fix-recursion(body, fn, student-fn-name)
      inner = A.s-fun(l, student-fn-name, params, args, ann, doc, new-inner-body, none, none, blocky)
      shadowed = inner.visit(V.shadow-visitor)

      inputs = input-set-name(fn)
      outputs = output-set-name(fn)

      new-body = A.s-block(
        l,
        [list:
          shadowed,
          # FIXME (pyret-lang): currently there's a bug that means opaque
          # exceptions cannot be compared for equality so we have to use this
          # workaround with a manual `cases`; when this gets fixed we should be
          # able to just use the result of `run-task` without any extra work.

          # output = cases ($Autogrder-Either.Either) run-task(lam(): $autograder-student-[fn]([args]) end):
          # | left(v) => left(v)
          # | right(exn) => right(exn-unwrap(exn))
          # end
          A.s-let(
            dummy-loc(),
            A.s-bind(dummy-loc(), true, A.s-name(dummy-loc(), "output"), A.a-blank),
            A.s-cases(
              dummy-loc(),
              A.a-dot(dummy-loc(), A.s-name(dummy-loc(), either-module-name), "Either"),
              A.s-app(
                dummy-loc(),
                A.s-id(dummy-loc(), A.s-name(dummy-loc(), "run-task")),
                [list:
                  A.s-lam(
                    dummy-loc(),
                    "", # empty string for anonymous lambda
                    [list:],
                    [list:],
                    A.a-blank,
                    "",
                    A.s-block(
                      dummy-loc(),
                      [list:                    
                        A.s-app(
                          dummy-loc(),
                          A.s-id(
                            dummy-loc(),
                            A.s-name(dummy-loc(), student-fn-name)
                          ),
                          all-args-ids
                        )
                      ]
                    ),
                    none,
                    none,
                    false
                  )
                ]
              ),
              [list:
                A.s-cases-branch(
                  dummy-loc(),
                  dummy-loc(),
                  "left",
                  [list:
                    A.s-cases-bind(
                      dummy-loc(),
                      A.s-cases-bind-normal,
                      A.s-bind(
                        dummy-loc(),
                        true,
                        A.s-name(dummy-loc(), "v"), A.a-blank
                      )
                    )
                  ],
                  A.s-block(
                    dummy-loc(),
                    [list:
                      A.s-app(
                        dummy-loc(),
                        A.s-dot(
                          dummy-loc(),
                          A.s-id(
                            dummy-loc(),
                            A.s-name(dummy-loc(), either-module-name)
                          ),
                          "left"
                        ),
                        [list:
                          A.s-id(dummy-loc(), A.s-name(dummy-loc(), "v"))
                        ]
                      )
                    ]
                  )
                ),
                A.s-cases-branch(
                  dummy-loc(),
                  dummy-loc(),
                  "right",
                  [list:
                    A.s-cases-bind(
                      dummy-loc(),
                      A.s-cases-bind-normal,
                      A.s-bind(
                        dummy-loc(),
                        true,
                        A.s-name(dummy-loc(), "exn"), A.a-blank
                      )
                    )
                  ],
                  A.s-block(
                    dummy-loc(),
                    [list:
                      A.s-app(
                        dummy-loc(),
                        A.s-dot(
                          dummy-loc(),
                          A.s-id(
                            dummy-loc(),
                            A.s-name(dummy-loc(), either-module-name)
                          ),
                          "right"
                        ),
                        [list:
                          A.s-app(
                            dummy-loc(),
                            A.s-id(dummy-loc(), A.s-name(dummy-loc(), "exn-unwrap")),
                            [list:
                              A.s-id(dummy-loc(), A.s-name(dummy-loc(), "exn"))
                            ]
                          )
                        ]
                      )
                    ]
                  )
                )
              ],
              false
            ),
            false
          ),
          # `$autograder-[fn]-diversity-inputs := $autograder-[fn]-diversity-inputs.add({[args]})`
          A.s-assign(
            dummy-loc(),
            A.s-name(dummy-loc(), inputs),
            A.s-app(
              dummy-loc(),
              A.s-dot(dummy-loc(), A.s-id(dummy-loc(), A.s-name(dummy-loc(), inputs)), "add"),
              [list: A.s-tuple(dummy-loc(), all-args-ids)]
            )
          ),
          # `$autograder-[fn]-diversity-outputs := $autograder-[fn]-diversity-outputs.add(output)`
          A.s-assign(
            dummy-loc(),
            A.s-name(dummy-loc(), outputs),
            A.s-app(
              dummy-loc(),
              A.s-dot(dummy-loc(), A.s-id(dummy-loc(), A.s-name(dummy-loc(), outputs)), "add"),
              [list: A.s-id(dummy-loc(), A.s-name(dummy-loc(), "output"))]
            )
          ),
          # cases ($Autograder-Either) output:
          # | left(v) => v
          # | right(exn) => raise(exn)
          # end
          A.s-cases(
            dummy-loc(),
            A.a-dot(dummy-loc(), A.s-name(dummy-loc(), either-module-name), "Either"),
            A.s-id(dummy-loc(), A.s-name(dummy-loc(), "output")),
            [list:
              A.s-cases-branch(
                dummy-loc(),
                dummy-loc(),
                "left",
                [list:
                  A.s-cases-bind(
                    dummy-loc(),
                    A.s-cases-bind-normal,
                    A.s-bind(
                      dummy-loc(),
                      true,
                      A.s-name(dummy-loc(), "v"), A.a-blank
                    )
                  )
                ],
                A.s-block(
                  dummy-loc(),
                  [list:
                    A.s-id(dummy-loc(), A.s-name(dummy-loc(), "v"))
                  ]
                )
              ),
              A.s-cases-branch(
                dummy-loc(),
                dummy-loc(),
                "right",
                [list:
                  A.s-cases-bind(
                    dummy-loc(),
                    A.s-cases-bind-normal,
                    A.s-bind(
                      dummy-loc(),
                      true,
                      A.s-name(dummy-loc(), "exn"), A.a-blank
                    )
                  )
                ],
                A.s-block(
                  dummy-loc(),
                  [list:
                    A.s-app(
                      dummy-loc(),
                      A.s-id(dummy-loc(), A.s-name(dummy-loc(), "raise")),
                      [list:
                        A.s-id(dummy-loc(), A.s-name(dummy-loc(), "exn"))
                      ]
                    )
                  ]
                )
              )
            ],
            false
          )
        ]
      )
      new-fn = A.s-fun(l, fn, params, all-args, ann, "", new-body, check-loc, checks, true)
      replaced = student.visit(V.make-fun-splicer(new-fn))
      some(replaced)
    | else => none
    end
  end
end

fun make-size-check(
  set-name :: String,
  check-name :: String,
  min :: Number
) -> A.Expr:
  # check "check-[set]":
  #   [set].size() is%(autograder$at-least) [min]
  # end
  A.s-check(
    dummy-loc(),
    some(check-name),
    A.s-block(
      dummy-loc(),
      [list:
        A.s-check-test(
          dummy-loc(),
          A.s-op-is(dummy-loc()),
          some(A.s-id(dummy-loc(), A.s-name(dummy-loc(), at-least-util))),
          A.s-app(
            dummy-loc(),
            A.s-dot(dummy-loc(), A.s-id(dummy-loc(), A.s-name(dummy-loc(), set-name)), "size"),
            [list:]
          ),
          some(A.s-num(dummy-loc(), min)),
          none
        )
      ]
    ),
    true
  )
end

fun remove-underscore-args(name :: String, args :: List<A.Bind>) -> List<A.Bind>:
  doc: ```
  For a function like `fun foo(a, _, b, _)`, when instrumenting, we must
  actually bind all arguments even if the student code doesn't care about them.
  This is so that we are able to refer to them, both when calling the student
  function (we still need to _provide_ the ignored arguments) and when adding
  the received arguments to the input set.
  ```
  fun convert-underscore(b :: A.Bind) -> A.Bind:
    cases (A.Bind) b:
    | s-bind(l, shadows, id, ann) =>
      new-id = cases (A.Name) id:
      | s-underscore(shadow l) =>
        A.s-name(l, GS.make-name("autograder$" + name + "-underscore-"))
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
  doc: ```
  This function converts a list of bindings to a list of identifier (or tuple)
  expressions, so we can provide them as arguments.
  ```
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

fun fix-recursion(body :: A.Expr, fn :: String, new-name :: String) -> A.Expr:
  fun same-name(n :: A.Name) -> Boolean:
    cases (A.Name) n:
    | s-name(_, actual) => actual == fn
    | else => false
    end
  end

  fun rename(n :: A.Name) -> A.Name:
    if same-name(n):
      cases (A.Name) n:
      | s-name(name-loc, _) => A.s-name(name-loc, new-name)
      | else => raise("unreachable")
      end
    else:
      n
    end
  end

  fun did-shadow(b :: A.Bind) -> Boolean:
    cases (A.Bind) b:
    | s-bind(_, shadows, name, _) => shadows and same-name(name)
    | s-tuple-bind(_, fields, as-name) =>
      L.any(did-shadow, fields) or did-shadow(as-name)
    end
  end

  fun should-continue(e :: A.Expr) -> Boolean:
    cases (A.Expr) e:
    | s-let(_, b, _, _) => not(did-shadow(b))
    | s-var(_, b, _) => not(did-shadow(b))
    | s-rec(_, b, _) => not(did-shadow(b))
    | else => true
    end
  end

  rec expr-visitor = A.default-map-visitor.{
    method s-id(self, l, n):
      A.s-id(l, rename(n))
    end,
    method s-rec(self, l, b, v):
      if did-shadow(b): A.s-rec(l, b, v)
      else: A.s-rec(l, b, v.visit(expr-visitor))
      end
    end,
    method s-block(self, l, stmts):
      fun folder(es):
        cases (List) es:
        | empty => empty
        | link(e, rest) =>
          fixed-e = e.visit(expr-visitor)
          if should-continue(e):
            link(fixed-e, folder(rest))
          else:
            link(fixed-e, rest)
          end
        end
      end
      A.s-block(l, folder(stmts))
    end,
    method s-cases-branch(self, l, pl, n, args, shadow body):
      real-binds = L.map(lam(cb):
        cases (A.CasesBind) cb:
        | s-cases-bind(_, _, b) => b
        end
      end, args)
      if L.any(did-shadow, real-binds):
        A.s-cases-branch(l, pl, n, args, body)
      else:
        A.s-cases-branch(l, pl, n, args, body.visit(expr-visitor))
      end
    end,
    method s-for(self, l, iter, bindings, ann, shadow body, blocky):
      real-binds = L.map(lam(fb):
        cases (A.ForBind) fb:
        | s-for-bind(_, b, _) => b
        end
      end, bindings)
      new-bindings = L.map(lam(fb):
        cases (A.ForBind) fb:
        | s-for-bind(shadow l, b, v) => A.s-for-bind(l, b, v.visit(expr-visitor))
        end
      end, bindings)
      if L.any(did-shadow, real-binds):
        A.s-for(l, iter, new-bindings, ann, body, blocky)
      else:
        A.s-for(l, iter, new-bindings, ann, body.visit(expr-visitor), blocky)
      end
    end,
    method s-fun(self, l, name, params, args, ann, doc, shadow body, check-loc, checks, blocky):
      fun-like(l, name, params, args, ann, doc, body, check-loc, checks, blocky, A.s-fun)
    end,
    method s-lam(self, l, name, params, args, ann, doc, shadow body, check-loc, checks, blocky):
      fun-like(l, name, params, args, ann, doc, body, check-loc, checks, blocky, A.s-lam)
    end,
    method s-method(self, l, name, params, args, ann, doc, shadow body, check-loc, checks, blocky):
      fun-like(l, name, params, args, ann, doc, body, check-loc, checks, blocky, A.s-method)
    end
  }

  fun fun-like(l, name, params, args, ann, doc, shadow body, check-loc, checks, blocky, constructor):
    new-checks = cases (Option) checks:
    | none => none
    | some(shadow checks) => some(checks.visit(expr-visitor))
    end
    if L.any(did-shadow, args):
      constructor(l, name, params, args, ann, doc, body, check-loc, new-checks, blocky)
    else:
      constructor(l, name, params, args, ann, doc, body.visit(expr-visitor), check-loc, new-checks, blocky)
    end
  end

  body.visit(expr-visitor)
end

# --- Utils ---

fun add-all(
  base :: A.Program,
  items :: List<A.Expr>,
  make-visitor
) -> A.Program:
  for fold(acc from base, i from items):
    acc.visit(make-visitor(i))
  end
end
