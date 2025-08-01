import error as ERR
import srcloc as S
import npm("pyret-lang", "../../src/arr/compiler/compile-structs.arr") as CS
include file("../../src/main.arr")
include file("../../src/graders/well-formed.arr")
import file("../meta/path-utils.arr") as P

check-well-formed = _check-well-formed

# TODO: test for file not existing

check "well-formed: unparsable":

  # FIXME: how to make this relative to current file
  check-well-formed(P.file("unparsable.arr"))
    is
    some(cannot-parse(
      ERR.parse-error-eof(
        S.srcloc(P.file("unparsable.arr"), 3, 1, 13, 3, 1, 13)
      )
    ))
end

check "well-formed: wf":
  check-well-formed(P.file("not-wf.arr"))
    satisfies
    {(x): cases(Option) x:
      | some(shadow x) =>
        is-List(x) and (x.length() > 0) and CS.is-wf-err(x.get(0))
      | else => false end}
end
