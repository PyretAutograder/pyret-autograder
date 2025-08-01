import error as ERR
import srcloc as S
include file("../../src/runners/well-formed.arr")
include file("../../src/grading.arr")
include file("../../src/core.arr")



check "well-formed: unparsable":
  # FIXME: how to make this relative to current file
  check-well-formed("./tests/files/unparsable.arr") 
    is
    block(cannot-parse(
      ERR.parse-error-eof(
        S.srcloc("./tests/files/unparsable.arr", 3, 1, 13, 3, 1, 13)
    )))
end


check "well-formed: wf":
  check-well-formed("./tests/files/not-wf.arr") 
    is
    block(not-wf(""))
end
