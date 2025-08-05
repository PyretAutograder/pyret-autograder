import error as ERR
import srcloc as S
import npm("pyret-lang", "../../src/arr/compiler/compile-structs.arr") as CS
include file("../../src/main.arr")
include file("../../src/graders/well-formed.arr")
import file("../meta/path-utils.arr") as P
import filesystem as FS

check-well-formed = _check-well-formed

# TODO: test for file not existing

check "well-formed: unparsable":
  path = P.file("unparsable.arr")

  # FIXME: how to make this relative to current file
  check-well-formed(path)
    is
    some(cannot-parse(
      {
        exn: ERR.parse-error-eof(
            S.srcloc(path, 3, 1, 13, 3, 1, 13)),
        message: "There were 0 potential parses.\n" +
          "Parse failed, next token is <end of file> at " + path + ", 3:1-3:1"
      },
      FS.read-file-string(path)
    ))
end

check "well-formed: wf":
  check-well-formed(P.file("not-wf.arr"))
    satisfies
    {(x): cases(Option) x:
      | some(shadow x) =>
        cases(WFBlock) x:
        | not-wf(shadow x) =>
          is-List(x) and (x.length() > 0) and CS.is-wf-err(x.get(0))
        | else => false
        end
      | else => false end}
end
