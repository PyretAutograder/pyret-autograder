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
include file("../utils/general.arr")
import file("../core.arr") as C
import file("../grading.arr") as G
import file("./repl-runner.arr") as R
import ast as A
import file("../../poc/jsonutils.arr") as JU
import render-error-display as RED
import lists as L
include either

provide:
  tmp-run-with-alternate-impl,
  tmp-run-with-alternate-checks,
  tmp-fmt-runtime-err,
  tmp-fmt-ai-err,
  tmp-fmt-ac-err,
  tmp-extract-ai-ran-program,
  tmp-extract-ac-ran-program,
end

type BlockSummary = { Number; Number; List<String> }

fun block-summary(block) -> Either<String, BlockSummary>:
  passed = block.get("passed").n()
  total = block.get("total").n()

  if is-left(passed) or is-left(total):
    left("cannot find json: " + to-repr(block))
  else:
    messages = block
      .get("results").v
      .and-then(lam(x): x.native().map(_.get-value("message")) end)
      .or-else([list:])
    right({ passed.v; total.v; messages })
  end
end

fun sum-summaries(blocks) -> Either<String, BlockSummary>:
  for fold(acc from right({0; 0; [list:]}), block from blocks):
    cases (Either) acc:
    | left(_) => acc
    | right({passed; total; messages}) =>
      cases (Either) block-summary(block):
      | left(err) => left(err)
      | right({p; t; m}) => right({ passed + p; total + t; messages + m })
      end
    end
  end
end

fun handle(res, path, selector :: R.CheckSelector):
  cases (Either) res:
  | left(err) => left(err)
  | right({json; program}) =>
    blocks = JU.pson(json).get(path)
    selected = cases (R.CheckSelector) selector:
      | check-named(name) => right([list: blocks.find-match("name", name)])
      | all-checks => blocks.elements()
    end
    summed = cases (Either) selected:
      | left(ops) => left("cannot find json: " + to-repr(ops))
      | right(shadow selected) => sum-summaries(selected)
    end
    cases (Either) summed:
    | left(err) => left(err)
    | right({passed; total; messages}) =>
      program-thunk = lam(): program end # otherwise debugging is a pain
      right({ passed; total; messages.join-str("\n"); program-thunk })
    end
  end
end


type AiInfo = Either<R.RunAltImplErr, { Number; Number; String; (-> A.Program) }>
type AcInfo = Either<R.RunAltChecksErr, { Number; Number; String; (-> A.Program) }>

fun tmp-run-with-alternate-impl(
  student-path :: String, alt-impl-path :: String, fun-name :: String
) -> AiInfo:
  res = R.run-with-alternate-impl(student-path, alt-impl-path, fun-name)
  handle(res, student-path, R.check-named(fun-name))
end

fun tmp-run-with-alternate-checks(
  student-path :: String, check-path :: String, selector :: R.CheckSelector
) -> AcInfo:
  res = R.run-with-alternate-checks(student-path, check-path, selector)
  handle(res, check-path, selector)
end

fun tmp-fmt-runtime-err(err :: R.RunChecksErr) -> String:
  cases(R.RunChecksErr) err:
    | compile-error(comp-err, _) =>
      "Program resulted in a compile error:\n" +
      for map(cr from comp-err):
        for map(e from cr.problems):
          RED.display-to-string(e.render-reason(), to-repr, empty)
        end.join-str(",\n")
      end.join-str("\n----\n")
    | runtime-error(run-err, _) =>
      "Program resulted in a runtime error:\n" +
      "```" + run-err.message + "\n```"
  end
end

fun tmp-fmt-ai-err(err) -> String:
  if is-string(err):
    err
  else:
    cases(R.RunAltImplErr) err:
      | ai-cannot-parse-student(shadow err) =>
        "Cannot parse student's file:\n" + to-repr(err)
      | ai-cannot-parse-alt-impl(shadow err) =>
        "Cannot parse specified alt-implementation file:\n" + to-repr(err)
      | ai-missing-replacement-fun(fun-name) =>
        "Cannot find alternate implementation of `" + fun-name +
        "` to use as a replacement."
      | ai-run-err(shadow err) => tmp-fmt-runtime-err(err)
    end
  end
end

fun tmp-fmt-ac-err(err) -> String:
  if is-string(err):
    err
  else:
    cases(R.RunAltChecksErr) err:
      | ac-cannot-parse-student(shadow err) =>
        "Cannot parse student's file:\n" + to-repr(err)
      | ac-cannot-parse-checks(shadow err) =>
        "Cannot parse specified check file:\n" + to-repr(err)
      | ac-cannot-find-check-block(name) =>
        "Cannot find a check block named `" + name + "` in the specified file."
      | ac-no-check-blocks =>
        "The specified file has no top-level check blocks."
      | ac-run-err(shadow err) => tmp-fmt-runtime-err(err)
    end
  end
end

fun tmp-extract-ai-ran-program(info :: AiInfo, constr) -> Option<G.RanProgram>:
  cases(Either) info:
    | left(err) =>
      ask:
        | is-string(err) then: none
        | R.is-ai-run-err(err) then: some(constr(err.err.program))
        | otherwise: none
      end
    | right({_; _; _; program}) => some(constr(program()))
  end
end

fun tmp-extract-ac-ran-program(info :: AcInfo, constr) -> Option<G.RanProgram>:
  cases(Either) info:
    | left(err) =>
      ask:
        | is-string(err) then: none
        | R.is-ac-run-err(err) then: some(constr(err.err.program))
        | otherwise: none
      end
    | right({_; _; _; program}) => some(constr(program()))
  end
end
