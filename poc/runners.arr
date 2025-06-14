provide:
  run-with-alternate-impl,
  run-extra-check
end

import ast as A
import file as F
import parse-pyret as PP
import either as E
import pprint as P
import string-dict as SD
import json as J
import pathlib as Path
import npm("pyret-lang", "../../src/arr/compiler/repl.arr") as R
import npm("pyret-lang", "../../src/arr/compiler/cli-module-loader.arr") as CLI
import npm("pyret-lang", "../../src/arr/compiler/compile-structs.arr") as CS
import npm("pyret-lang", "../../src/arr/compiler/compile-lib.arr") as CL
import runtime-lib as RT
import load-lib as LL
import require-util as RU
include js-file("../src/proj-dir")

import file("./visitors.arr") as V
import file("./jsonutils.arr") as JU

project-root = get-proj-dir()

context = {
  current-load-path: Path.resolve(project-root),
  cache-base-dir: Path.resolve("./.pyret/compiled"),

  compiled-read-only-dirs: [list: Path.join(
    # HACK: see if a `main` can be added to pyret-npm instead
    RU.resolve("pyret-lang", project-root),
    "../../../../pyret-npm/pyret-lang/build/phaseA/lib-compiled")],
  url-file-mode: CS.all-remote
}
repl = R.make-repl(
  RT.make-runtime(),
  [SD.mutable-string-dict:],
  LL.empty-realm(),
  context,
  lam(): CLI.module-finder end
)

fun run-with-alternate-impl(student-path, chaff-path, fun-name):
  student = load-syntax(student-path)
  chaff = load-syntax(chaff-path)
  to-run = replace-fun({base: student, replacement: chaff, fun-name: fun-name})

  without-checks = remove-checks(to-run)

  result = run(without-checks)

  json = J.read-json(result)

  JU.pson(json).get(student-path).find-match("name", fun-name)
end

fun run-extra-check(student-path, check-path, check-name) block:
  student = load-syntax(student-path)

  checks = load-syntax(check-path)

  without-checks = remove-checks(student)
  extra-check = cases(Option) get-check-named(checks, check-name):
    | none => raise("Missing check block named " + check-name + " in reference.")
    | some(c) => c
  end

  prog = add-to-program(without-checks, extra-check)

  #print(prog.tosource().pretty(80))

  result = run(prog)

  json = J.read-json(result)

  JU.pson(json).get(student-path).find-match("name", check-name)
end

fun load-syntax(path :: String):
  content = F.file-to-string(path)
  maybe-ast = PP.maybe-surface-parse(content, path)
  cases(E.Either) maybe-ast:
    | left(err) => raise(err)
    | right(ast) => ast
  end
end

fun replace-fun(opts ::
    { base :: A.Program,
      replacement :: A.Program,
      fun-name :: String }) block:

  fun-extractor = V.make-fun-extractor(opts.fun-name)
  opts.replacement.visit(fun-extractor)
  fun-to-splice = cases(Option) fun-extractor.get-target():
    | none => raise("Missing " + opts.fun-name + " in replacement.")
    | some(c) => c.visit(V.shadow-visitor)
  end

  fun-splicer = V.make-fun-splicer(fun-to-splice)

  opts.base.visit(fun-splicer)
end

fun remove-checks(stx :: A.Program):
  stx.visit(V.make-check-filter(lam(_): false end))
end

fun get-check-named(stx :: A.Program, str :: String) block:
  extractor = V.make-check-extractor(str)
  stx.visit(extractor)
  extractor.get-target()
end

fun add-to-program(stx :: A.Program, expr :: A.Expr):
  stx.visit(V.make-program-appender(expr))
end

fun run(ast):
  i = repl.make-definitions-locator(lam(): "" end, CS.standard-globals).{
    method get-module(self):
      CL.pyret-ast(ast)
    end
  }
  result = repl.restart-interactions(i, CS.default-compile-options.{checks-format: "json"})
  if LL.is-success-result(result.v):
    LL.render-check-results(result.v).message
  else:
    LL.render-error-message(result.v).message
  end
end
