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
import filelib as FL
import filesystem as FS
import parse-pyret as PP
import ast as A
import error as E
include either

provide:
  data ParsePathErr,
  type InternalParseError,
  parse-path
end

type InternalParseError = {
  exn :: E.ParseError,
  message :: String
}

data ParsePathErr:
  | path-doesnt-exist(path :: String)
  | path-isnt-file(path :: String)
  | cannot-parse(inner :: InternalParseError, content :: String)
end

fun parse-path(path :: String) -> Either<ParsePathErr, A.Program>:
  if not(FS.exists(path)):
    left(path-doesnt-exist(path))
  else if not(FL.is-file(path)):
    left(path-isnt-file(path))
  else:
    content = FS.read-file-string(path) # XXX: this can raise
    result = PP.maybe-surface-parse(content, path)
    cases (Either) result:
      | left(err) => left(cannot-parse(err, content))
      | right(prog) => right(prog)
    end
  end
end

