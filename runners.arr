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
# import file("pyret/src/arr/compiler/repl.arr") as R
import file("my-repl.arr") as R
import file("pyret/src/arr/compiler/cli-module-loader.arr") as CLI
import file("pyret/src/arr/compiler/compile-structs.arr") as CS
import file("pyret/src/arr/compiler/compile-lib.arr") as CL
import runtime-lib as RT
import load-lib as LL

import file("./visitors.arr") as V
import file("./jsonutils.arr") as JU

include file("./profiling.arr")

context = {
  current-load-path: Path.resolve("./"),
  cache-base-dir: Path.resolve("./.pyret/compiled"),
  compiled-read-only-dirs: link("node_modules/pyret-npm/pyret-lang/build/phaseA/lib-compiled", empty),
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
  time-ctx = init-time()

  student = load-syntax(student-path)
  student-time = time(time-ctx)

  chaff = load-syntax(chaff-path)
  chaff-time = time(time-ctx)

  to-run = replace-fun({base: student, replacement: chaff, fun-name: fun-name})
  to-run-time = time(time-ctx)

  without-checks = remove-checks(to-run)
  without-checks-time = time(time-ctx)

  result = run(without-checks)
  result-run-time = time(time-ctx)

  json = J.read-json(result)
  json-time = time(time-ctx)

  spy "run-with-alternate-impl":
    student-time, chaff-time, to-run-time, without-checks-time, result-run-time, json-time
  end

  JU.pson(json).get(student-path).find-match("name", fun-name)
end

fun run-extra-check(student-path, check-path, check-name) block:
  time-ctx = init-time()
  student = load-syntax(student-path)
  student-time = time(time-ctx)

  checks = load-syntax(check-path)
  checks-time = time(time-ctx)
  
  without-checks = remove-checks(student)
  without-checks-time = time(time-ctx)

  extra-check = cases(Option) get-check-named(checks, check-name):
    | none => raise("Missing check block named " + check-name + " in reference.")
    | some(c) => c
  end
  
  prog = add-to-program(without-checks, extra-check)
  prog-time = time(time-ctx)

  #print(prog.tosource().pretty(80))
  
  result = run(prog)
  result-time = time(time-ctx)

  # print(result)
  # print("\n")

  json = J.read-json(result)
  json-time = time(time-ctx)

  spy "run-extra-check":
    student-time, checks-time, without-checks-time, without-checks-time, prog-time,
    result-time, json-time
  end

  JU.pson(json).get(student-path).find-match("name", check-name)
end

fun load-syntax(path :: String):
  time-ctx = init-time()

  content = F.file-to-string(path)
  content-time = time(time-ctx)

  maybe-ast = PP.maybe-surface-parse(content, path)
  maybe-ast-time = time(time-ctx)

  spy "load-syntax": content-time, maybe-ast-time end

  cases(E.Either) maybe-ast:
    | left(err) => raise(err)
    | right(ast) => ast
  end
end

fun replace-fun(opts :: 
    { base :: A.Program,
      replacement :: A.Program,
      fun-name :: String }) block:
  time-ctx = init-time()

  fun-extractor = V.make-fun-extractor(opts.fun-name)
  fun-extractor-time = time(time-ctx)

  opts.replacement.visit(fun-extractor)
  replacement-visit-time = time(time-ctx)

  fun-to-splice = cases(Option) fun-extractor.get-target():
    | none => raise("Missing " + opts.fun-name + " in replacement.")
    | some(c) => c.visit(V.shadow-visitor)
  end
  fun-to-splice-time = time(time-ctx)

  fun-splicer = V.make-fun-splicer(fun-to-splice)
  fun-spicer-time = time(time-ctx)

  res = opts.base.visit(fun-splicer)
  res-time = time(time-ctx)

  spy "replace-fun":
    fun-extractor-time, replacement-visit-time, fun-to-splice-time,
    fun-spicer-time, res-time
  end

  res
end

fun remove-checks(stx :: A.Program):
  time-ctx = init-time()

  res = stx.visit(V.make-check-filter(lam(_): false end))

  spy "remove-checks":
    res-time: time(time-ctx)
  end

  res
end

fun get-check-named(stx :: A.Program, str :: String) block:
  time-ctx = init-time()

  extractor = V.make-check-extractor(str)
  extractor-time = time(time-ctx)

  stx.visit(extractor)
  visit-time = time(time-ctx)

  res = extractor.get-target()
  res-time = time(time-ctx)

  spy "get-check-named":
    extractor-time, visit-time, res-time
  end

  res
end

fun add-to-program(stx :: A.Program, expr :: A.Expr):
  time-ctx = init-time()

  res = stx.visit(V.make-program-appender(expr))
  res-time = time(time-ctx)

  spy "add-to-program": res-time end

  res
end

fun run(ast):
  time-ctx = init-time()

  i = repl.make-definitions-locator(lam(): "" end, CS.standard-globals).{
    method get-module(self):
      CL.pyret-ast(ast)
    end
  }
  i-time = time(time-ctx)

  result = repl.restart-interactions(i, CS.default-compile-options.{checks-format: "json"})
  result-repl-time = time(time-ctx)

  res = LL.render-check-results(result.v).message
  res-time = time(time-ctx)

  spy "run": i-time, result-repl-time, res-time end

  res
end
