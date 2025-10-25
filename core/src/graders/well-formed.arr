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
import npm("pyret-lang", "../../src/arr/compiler/well-formed.arr") as WF
import npm("pyret-lang", "../../src/arr/compiler/compile-structs.arr") as CS
import npm("pyret-lang", "../../src/arr/compiler/ast-util.arr") as AU
import file("../common/ast.arr") as CA
import file("../grading-builders.arr") as GB
import file("../grading.arr") as G
import file("../core.arr") as C
import file("../common/markdown.arr") as MD
import render-error-display as RED
import error as ERR
import filesystem as FS
import filelib as FL
include either
include from C: type Id end

provide:
  mk-well-formed,
  data WFBlock,
  check-well-formed as _check-well-formed,
  fmt-well-formed as _fmt-well-formed
end

data WFBlock:
  | path-doesnt-exist(path :: String)
  | path-isnt-file(path :: String)
  | cannot-parse(inner :: CA.InternalParseError, content :: String)
  | not-wf(problems :: List<CS.CompileError>)
end

fun check-well-formed(filepath :: String) -> Option<WFBlock>:
  cases (Either) CA.parse-path(filepath):
    | left(err) =>
      cases (CA.ParsePathErr) err:
        | path-doesnt-exist(path) => some(path-doesnt-exist(path))
        | path-isnt-file(path) => some(path-isnt-file(path))
        | cannot-parse(inner, content) => some(cannot-parse(inner, content))
      end
    | right(ast) =>
      ast-ended = AU.append-nothing-if-necessary(ast)
      wf-check-res = WF.check-well-formed(ast-ended)
      cases (CS.CompileResult) wf-check-res:
        | err(problems) => some(not-wf(problems))
        | ok(_) => none # TODO: also check for other compilation error
      end
  end
end

fun list-files(path :: String) -> Option<List<String>>:
  dirname = FS.dirname(path)
  if FS.exists(dirname):
    some(FL.list-files(dirname))
  else:
    none
  end
end

fun fmt-well-formed(reason :: WFBlock) -> GB.ComboAggregate:
  student = cases (WFBlock) reason block:
    | path-doesnt-exist(path) =>
      "Cannot find a submission to grade; expected to find a file at " +
      "`" + MD.escape-inline-code(path) + "`, but didn't find anything there." +
      cases (Option) list-files(path):
        | some(files) =>
          "\n\n" +
          "The autograder can see the following files in the same directly, " +
          "perhaps you have misnamed your file:\n" +
          "```\n" +
          files.join-str("\n") + # TODO: escape
          "\n```"
        | none => ""
      end
    | path-isnt-file(path) =>
      "Cannot find a submission to grade; expected to find a file at " +
      "`" + MD.escape-inline-code(path) + "`, but found somthing else. Make " +
      "sure you submit a file, not a directory."
    | cannot-parse(inner, content) =>
      src-available = lam(x):
        false # TODO: would be nice to embed with src-available
      end
      exn = inner.exn
      msg = inner.message
      "The submitted file cannot be understood by pyret. Please make sure that " +
      "your file can run. Pyret reports the following issue:\n\n" +
      "```" +
      RED.display-to-string(exn.render-fancy-reason(src-available), to-repr, empty) # TODO: escape
      + "\n\n" + msg + "\n```"

    | not-wf(problems) =>
      suf = if problems.length() == 1: "" else: "s" end
      "The submitted file has problems. Please make sure that your file can run. " +
      "Pyret reported the following problem" + suf + " about your submitted file." +
      "\n```" +
      for map(problem from problems):
        RED.display-to-string(problem.render-fancy-reason(), to-repr, empty)
      end.join-str("\n\n--------------------\n")
  end ^ G.output-markdown
  staff = none
  {student; staff}
end

fun mk-well-formed(id :: Id, deps :: List<Id>, filepath :: String):
  name = "Wellformed Check"
  checker = lam(): check-well-formed(filepath) end
  GB.mk-guard(id, deps, checker, name, fmt-well-formed)
end


