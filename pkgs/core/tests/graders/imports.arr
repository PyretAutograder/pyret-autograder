import file("../meta/path-utils.arr") as P
include file("../../src/graders/imports.arr")
import file("../../src/common/ast.arr") as CA

check-import-required = _check-import-required
check-import-allowlist = _check-import-allowlist
fmt-import-required = _fmt-import-required
fmt-import-allowlist = _fmt-import-allowlist

check "import-required: found with correct binding":
  check-import-required(P.file("has-imports.arr"), "tables", some("T")) is none
  check-import-required(P.file("has-imports.arr"), "image", some("I")) is none
end

check "import-required: found with any binding":
  check-import-required(P.file("has-imports.arr"), "tables", none) is none
  check-import-required(P.file("has-imports.arr"), "image", none) is none
end

check "import-required: not found":
  check-import-required(P.file("has-imports.arr"), "math", none)
    is some(import-not-found("math"))
  check-import-required(P.file("no-imports.arr"), "tables", none)
    is some(import-not-found("tables"))
end

check "import-required: wrong binding":
  check-import-required(P.file("has-imports.arr"), "tables", some("Tbl"))
    is some(wrong-binding("tables", "Tbl", "T"))
end

check "import-allowlist: all allowed":
  check-import-allowlist(P.file("has-imports.arr"), [list: "tables", "image"]) is none
  check-import-allowlist(P.file("has-imports.arr"), [list: "tables", "image", "math"]) is none
end

check "import-allowlist: no imports":
  check-import-allowlist(P.file("no-imports.arr"), [list: "tables"]) is none
  check-import-allowlist(P.file("no-imports.arr"), [list:]) is none
end

check "import-allowlist: forbidden":
  result = check-import-allowlist(P.file("has-imports.arr"), [list: "tables"])
  result is some(forbidden-imports([list: "image"], [list: "tables"]))
end

check "import-allowlist: all forbidden":
  result = check-import-allowlist(P.file("has-imports.arr"), [list:])
  result is some(forbidden-imports([list: "tables", "image"], [list:]))
end

check "fmt-import-required: smoke":
  fmt-import-required(ir-parser-error(CA.path-doesnt-exist("/invalid.arr"))) does-not-raise
  fmt-import-required(import-not-found("tables")) does-not-raise
  fmt-import-required(wrong-binding("tables", "T", "Tbl")) does-not-raise
end

check "fmt-import-allowlist: smoke":
  fmt-import-allowlist(ia-parser-error(CA.path-doesnt-exist("/invalid.arr"))) does-not-raise
  fmt-import-allowlist(forbidden-imports([list: "image"], [list: "tables"])) does-not-raise
end
