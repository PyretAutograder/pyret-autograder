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

