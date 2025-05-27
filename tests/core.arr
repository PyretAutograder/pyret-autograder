include file("../src/core.arr")
include file("../src/utils.arr")

import lists as L
import sets as S
import string-dict as SD

data ExBlockReason:
  | invalid
end

check "execute":
  execute(empty) is [SD.string-dict:]

  single = [list: node("1", [list:], lam(): done(1) end, true)]
  execute(single) is [SD.string-dict: "1", done(1)]

  simple_dep = [list: node("pass_guard", [list:], lam(): proceed end, false),
                      node("has_dep", [list: "pass_guard"], lam(): done(1) end, true)]
  execute(simple_dep) is [SD.string-dict: "pass_guard", proceed, "has_dep", done(1)]
  
  blocking_simple_dep = [list: node("block_guard", [list:], lam(): block(invalid) end, false),
                               node("has_dep", [list: "block_guard"], lam(): done(1) end, true)]
  execute(blocking_simple_dep) is [SD.string-dict: "block_guard", block(invalid), "has_dep", skipped("block_guard")]

  internal_failure = [list: node("failing", [list:], lam(): internal-error("catastrofic error") end, false),
                            node("has_dep", [list: "failing"], lam(): done(1) end, true)]

  execute(internal_failure) is [SD.string-dict: "failing", internal-error("catastrofic error"), "has_dep", skipped("failing")]

  blocking_dep = [list: node("block_guard", [list:], lam(): block(invalid) end, false),
                        node("has_dep1", [list: "block_guard"], lam(): done(1) end, true),
                        node("has_dep2", [list: "has_dep1"], lam(): done(2) end, true)]
  execute(blocking_dep) is [SD.string-dict: "block_guard", block(invalid), 
                                            "has_dep1", skipped("block_guard"),
                                            "has_dep2", skipped("block_guard")]
  dep = [list: node("pass_guard", [list:], lam(): proceed end, false),
               node("has_dep1", [list: "pass_guard"], lam(): done(1) end, true),
               node("has_dep2", [list: "has_dep1"], lam(): done(2) end, true)]
  execute(dep) is [SD.string-dict: "pass_guard", proceed, 
                                   "has_dep1", done(1),
                                   "has_dep2", done(2)]
end
