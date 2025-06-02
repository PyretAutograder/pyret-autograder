import file as F
import parse-pyret as PP
import either as E
import ast as A

provide:
  parse-path
end

fun parse-path(path :: String) -> E.Either<A.Program>:
  content = F.file-to-string(path)
  PP.maybe-surface-parse(content, path)
end

