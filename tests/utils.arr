include file("../src/utils.arr")
import string-dict as SD

check "unique":
  unique([list:]) is [list:]
  unique([list: 1, 2, 3]) is [list: 1, 2, 3]
  unique([list: "a", "b", "c"]) is [list: "a", "b", "c"]
  unique([list: 1, 1, 2]) is [list: 1, 2]
end

check "has-duplicates":
  has-duplicates([list:]) is false
  has-duplicates([list: 1]) is false
  has-duplicates([list: 1, 1]) is true
end

check "list-to-stringdict":
  list-to-stringdict([list:]) is [SD.string-dict:]
  list-to-stringdict([list: {"key1"; 1}, {"key2"; 2}]) is [SD.string-dict: "key1", 1, "key2", 2]
end
