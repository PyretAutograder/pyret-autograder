#|
  Copyright (C) 2025 dbp <dbp@dbpmail.net>

  This file is part of pyret-autograder-pawtograder.

  pyret-autograder-pawtograder is free software: you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public License as
  published by the Free Software Foundation, either version 3 of the License,
  or (at your option) any later version.

  pyret-autograder-pawtograder is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser
  General Public License for more details.

  You should have received a copy of the GNU Lesser General Public License
  with pyret-autograder-pawtograder. If not, see <http://www.gnu.org/licenses/>.
|#

import npm("pyret-autograder", "main.arr") as AG
import ast as A
import npm("pyret-autograder", "common/ast.arr") as CA
import npm("pyret-lang", "../../src/arr/compiler/ast-util.arr") as AU
import json as J
import string-dict as SD
import filesystem as FS
import lists as L

include either


provide:
  data DocsInfo,
  mk-docchk,
end

MIN-DOC-LEN = 10

data DocsInfo:
  | parser-error(err :: CA.ParsePathErr) # this should've been caught by wf
  | fn-not-defined(name :: String) # this should have been caught by function-defined
  | docs-missing-or-short(name :: String)
  | docs-present
end

fun check-docs(
  path :: String,
  name :: String
) -> DocsInfo:
  cases (Either) CA.parse-path(path):
    | left(err) => parser-error(err)
    | right(ast) =>
      ast-ended = AU.append-nothing-if-necessary(ast)
      cases (A.Program) ast-ended:
        | s-program(_, _, _, _, _, _, body) =>
          cases (A.Expr) body:
            | s-block(_, stmts) => find-docs(stmts, name)
            | else => fn-not-defined(name)
          end
      end
  end
end

fun find-docs(
  stmts :: List<A.Expr>,
  fn-name :: String
) -> DocsInfo:
  cases (List) stmts:
    | empty => fn-not-defined(fn-name)
    | link(st, rest) =>
      cases (A.Expr) st:
        | s-fun(_, actual-name, _, args, _, doc, _, _, _, _) =>
          if actual-name == fn-name:
            if string-length(doc) >= MIN-DOC-LEN:
              docs-present
            else:
              docs-missing-or-short(fn-name)
            end
          else:
            find-docs(rest, fn-name)
          end
        | else => find-docs(rest, fn-name)
      end
  end
end
  
fun fmt-docs(score, info :: DocsInfo) -> AG.ComboAggregate:
  general = cases (DocsInfo) info:
    | parse-err(_) => AG.output-text("couldn't parse")
    | fn-not-defined(_) => AG.output-text("function missing")
    | docs-missing-or-short(_) =>
      AG.output-markdown("Function either missing docstring, or docstring not sufficient.")
    | docs-present =>
      AG.output-markdown("Doc string present.")
  end
  staff = none
  {general; staff}
end

fun mk-docchk(
  id :: AG.Id, deps :: List<AG.Id>, path :: String, fn-name :: String, max-score :: Number
):
  name = "Doc String Checker"
  scorer = lam():
    info = check-docs(path, fn-name)
    cases (DocsInfo) info:
    | docs-present => right({1; docs-present})
    | else => right({0; info})
    end
  end
  fmter = fmt-docs
  part = some(fn-name)
  AG.mk-simple-scorer(id, deps, scorer, name, max-score, fmter, part)
end