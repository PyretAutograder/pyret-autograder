#|
  Copyright (C) 2025 ironmoon <me@ironmoon.dev>

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
import json as J
import string-dict as SD
import filesystem as FS
import lists as L
import is-kebab-case, is-capital-kebab-case from js-file("../utils/naming")

include either

provide:
  data StyleInfo,
  mk-style,
end

MAX-LINE-LENGTH = 100

# TODO: improve scoring customization

data Style:
  | line-length(actual :: Number)
  | function-name(name :: String)
  | other-name(name :: String)
  | function-spacing
sharing:
  method to-string(self):
    cases (Style) self:
      | line-length(actual) =>
        "Line longer than " + num-to-string(MAX-LINE-LENGTH) + " (" +
        num-to-string(actual) + ")"
      | function-name(name) => "Function name isn't kabab-case: " + name
      | other-name(name) => "Name not kebab-case or CAPITAL-KEBAB-CASE: " + name
      | function-spacing => "Missing blank line before top-level function"
    end
  end
end

data Violation:
  violation(line :: Number, style :: Style)
end

data StyleInfo:
  | parser-error(err :: CA.ParsePathErr)
  | style-info(file :: String, violations :: List<Violation>)
end

fun is-valid-name(allow-const :: Boolean, name :: String) -> Boolean:
  if allow-const:
    is-kebab-case(name) or is-capital-kebab-case(name)
  else:
    is-kebab-case(name)
  end
end

fun check-line-length(program :: String):
  for fold(
    {lnum; acc} from {1; [list:]},
    line from string-split-all(program, "\n")
  ):
    len = string-length(line)
    new-acc = if len > MAX-LINE-LENGTH:
      link(violation(lnum, line-length(len)), acc)
    else:
      acc
    end
    {lnum + 1; new-acc}
  end.{1}.reverse()
end

fun check-fun-names(ast :: A.Program) block:
  var violations = [list:]

  visitor = A.default-iter-visitor.{
    method s-fun(self, l, name, _, _, _, _, body, _, _check, _):
      if not(is-valid-name(false, name)) block:
        line = l.start-line
        violations := link(violation(line, function-name(name)), violations)
        true
      else:
        true
      end and body.visit(self) and self.option(_check)
    end
  }
  ast.visit(visitor)
  violations.reverse()
end

fun check-binds(ast :: A.Program) block:
  var violations = [list:]

  visitor = A.default-iter-visitor.{
    method s-bind(self, l, _, name, _):
      shadow name = if A.is-s-underscore(name) or A.is-s-atom(name):
        "" # don't want spurious errors around casing, etc
        else:
          name.s
        end
      if not(is-valid-name(true, name)) block:
        line = l.start-line
        violations := link(violation(line, other-name(name)), violations)
        true
      else:
        true
      end
    end
  }
  ast.visit(visitor)
  violations.reverse()
end

fun check-tl-fun-spacing(ast :: A.Program):
  cases (A.Program) ast:
    | s-program(_, _, _, _, _, _, body) =>
      cases (A.Expr) body:
        | s-block(_, stmts) =>
          for fold({prev-end; prev-fun; violations} from {-1; false; [list:]},
                   stmt from stmts):
            cases(A.Expr) stmt:
              | s-fun(l, _, _, _, _, _, _, _, _, _) =>
                start = l.start-line
                _end = l.end-line
                if (start - prev-end) < 2:
                  print("pre-fun: " + torepr(prev-fun) + "\n")
                  print("prev: " + torepr(prev-end) + "\n")
                  print("start: " + torepr(start) + "\n")
                  new-violations = link(
                    violation(start, function-spacing), violations
                  )
                  {_end; true; new-violations}
                else:
                  {_end; true; violations}
                end
              | else =>
                _end = stmt.l.end-line
                {_end; false; violations}
            end
          end.{2}.reverse()
        | else => [list:]
      end
  end
end

fun score-style(
  path :: String, base-filename :: String
):
  cases (Either) CA.parse-path(path):
    | left(err) =>
      right({0; parser-error(err)})
    | right(prog) =>
      point-violations = check-fun-names(prog) +
                         check-binds(prog) +
                         check-tl-fun-spacing(prog)
      info = style-info(base-filename, check-line-length(FS.read-file-string(path)) + point-violations)
      num = L.length(point-violations)
      score = 1 - if num > 10: 0 else: 0.1 * num end
      right({score; info})
  end
end

fun fmt-style(score, info :: StyleInfo) -> AG.ComboAggregate:
  general = cases (StyleInfo) info:
    | parse-err(_) => AG.output-text("couldn't parse")
    | style-info(_, _) =>
      if score == 1:
        AG.output-markdown("No style issues found.")
      else:
        AG.output-markdown("Style issues found, see your file's comments.")
      end
  end
  staff = none
  {general; staff}
end

fun mk-style(
  id :: AG.Id, deps :: List<AG.Id>, path :: String, base-filename :: String,
  max-score :: Number
):
  name = "Automated Style Grading"
  scorer = lam():
    score-style(path, base-filename)
  end
  fmter = fmt-style
  part = none
  AG.mk-simple-scorer(id, deps, scorer, name, max-score, fmter, part)
end
