#|
  Copyright (C) 2025 ironmoon <me@ironmoon.dev>

  This file is part of pyret-autograder.

  pyret-autograder is free software: you can redistribute it and/or modify it
  under the terms of the GNU Lesser General Public License as published by the
  Free Software Foundation, either version 3 of the License, or (at your option)
  any later version.

  pyret-autograder is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License
  for more details.

  You should have received a copy of the GNU Lesser General Public License
  with pyret-autograder. If not, see <http://www.gnu.org/licenses/>.
|#
import ast as A
import file as F
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
import file("./visitors.arr") as V
import file("./ast.arr") as CA
include js-file("./runtime")
import js-file("./interop/module-return") as MR
include either

include js-file("../tools/debugging")

provide:
  data *,
  type *,
  run-with-alternate-impl,
  run-with-alternate-checks,
end

# TODO: deal with this!!!
# type RunChecksResult = {
#   program :: A.Program,
#   passed :: Number,
#   total :: Number,
# }
type RunChecksResult = {J.JSON; A.Program}

pyret-lang-compiled = cases(Option) get-env("PA_PYRET_LANG_COMPILED_PATH"):
  | some(path) => string-split-all(path, ":")
  | none =>
    [list: Path.join(
      # HACK: see if a `main` can be added to pyret-npm instead
      RU.resolve("pyret-lang", runtime-dirname()),
      "../../../../pyret-npm/pyret-lang/build/phaseA/lib-compiled"
    )]
end

current-load-path = cases(Option) get-env("PA_CURRENT_LOAD_PATH"):
  | some(path) => path
  | none => Path.resolve(".")
end

cache-base-dir = cases(Option) get-env("PA_CACHE_BASE_DIR"):
  | some(path) => path
  | none => Path.resolve("./.pyret/compiled")
end

context = {
  current-load-path: current-load-path,
  cache-base-dir: cache-base-dir,

  compiled-read-only-dirs: pyret-lang-compiled,
  url-file-mode: CS.all-remote
}
repl = R.make-repl(
  RT.make-runtime(),
  [SD.mutable-string-dict:],
  LL.empty-realm(),
  context,
  lam(): CLI.module-finder end
)

fun remove-checks(stx :: A.Program, check-name :: Option<String>) -> A.Program:
  pred = check-name
         .and-then(lam(cn): lam(actual-name): cn == actual-name end end)
         .or-else(lam(_): false end)
  stx.visit(V.make-check-filter(pred))
end

#--------------------------[run-with-alternate-impl]--------------------------#

data RunAltImplErr:
  | ai-cannot-parse-student(err :: CA.ParsePathErr)
  | ai-cannot-parse-alt-impl(err :: CA.ParsePathErr)
  | ai-missing-replacement-fun(fun-name :: String)
  | ai-run-err(err :: RunChecksErr)
end

fun run-with-alternate-impl(
  student-path :: String, alt-impl-path :: String, fun-name :: String
) -> Either<RunAltImplErr, RunChecksResult> block:
  cases(Either) CA.parse-path(student-path):
  | left(err) => left(ai-cannot-parse-student(err))
  | right(student) =>
    cases(Either) CA.parse-path(alt-impl-path):
    | left(err) => left(ai-cannot-parse-alt-impl(err))
    | right(alt-impl) =>
      cases(Either) replace-fun(student, alt-impl, fun-name):
      | left(err) => left(err)
      | right(to-run) =>
        filtered-checks = remove-checks(to-run, some(fun-name))
        cases(Either) run(filtered-checks):
        | left(err) => left(ai-run-err(err))
        | right(res) => right(res)
        end
      end
    end
  end
end

fun replace-fun(
  base :: A.Program, replacement :: A.Program, fun-name :: String
) -> Either<RunAltImplErr, A.Program> block:
  fun-extractor = V.make-fun-extractor(fun-name)
  replacement.visit(fun-extractor)
  cases(Option) fun-extractor.get-target():
    | none => left(ai-missing-replacement-fun(fun-name))
    | some(f) =>
      fun-to-splice = f.visit(V.shadow-visitor)
      fun-splicer = V.make-fun-splicer(fun-to-splice)
      right(base.visit(fun-splicer))
  end
end

#-------------------------[run-with-alternate-checks]-------------------------#

data RunAltChecksErr:
  | ac-cannot-parse-student(err :: CA.ParsePathErr)
  | ac-cannot-parse-checks(err :: CA.ParsePathErr)
  | ac-cannot-find-check-block(name :: String)
  | ac-run-err(err :: RunChecksErr)
end

fun run-with-alternate-checks(
  student-path :: String, checks-path :: String, check-name :: String
) -> Either<RunAltChecksErr, RunChecksResult> block:
  cases(Either) CA.parse-path(student-path):
  | left(err) => left(ac-cannot-parse-student(err))
  | right(student) =>
    cases(Either) CA.parse-path(checks-path):
    | left(err) => left(ac-cannot-parse-checks(err))
    | right(checks) =>
      without-checks = remove-checks(student, none)
      cases(Either) get-check-named(checks, check-name):
      | left(err) => left(err)
      | right(extra-check) =>
        prog = add-to-program(without-checks, extra-check)
        cases(Either) run(prog):
        | left(err) => left(ac-run-err(err))
        | right(res) => right(res)
        end
      end
    end
  end
end

fun get-check-named(
  stx :: A.Program, str :: String
) -> Either<RunAltChecksErr, A.Program> block:
  extractor = V.make-check-extractor(str)
  stx.visit(extractor)
  cases(Option) extractor.get-target():
    | none => left(ac-cannot-find-check-block(str))
    | some(c) => right(c)
  end
end

fun add-to-program(stx :: A.Program, expr :: A.Expr):
  stx.visit(V.make-program-appender(expr))
end

#---------------------------------[run-checks]---------------------------------#

data RunChecksErr:
  | compile-error(x :: Any, program :: A.Program) # TODO: whats in here?
  | runtime-error(x :: Any, program :: A.Program)
end

fun run(program :: A.Program) -> Either<RunChecksErr, RunChecksResult> block:
  locator = repl.make-definitions-locator(lam(): nothing end, CS.standard-globals).{
    method get-module(self):
      CL.pyret-ast(program)
    end
  }
  compile-options = CS.default-compile-options.{checks-format: "json"}

  identity-spy = lam(x):
    spy: x end
    x
  end
  mk-eff-identity = lam(f): lam(x) block:
    f(x)
    x
  end end
  identity-print-json = mk-eff-identity(print-json)
  identity-print-raw = mk-eff-identity(print-raw)

  cases(Either) repl.restart-interactions(locator, compile-options):
    | left(err) =>
      err
      ^ compile-error(_, program)
      ^ left
    | right(val) =>
      if LL.is-success-result(val):
        val
        ^ MR.extract-check-results
        ^ identity-spy
        ^ _.message
        # ^ identity-print-json
        ^ J.read-json
        # ^ _.native()
        ^ {(x): right({x; program})}
      else:
        LL.render-error-message(val)
        ^ runtime-error(_, program)
        ^ left
      end
  end
  # ^ identity-spy
end


#----------------------------------run-checks----------------------------------#
