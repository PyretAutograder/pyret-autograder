# import lists as lists

fun overlap(doc1 :: List<String>%(is-link), doc2 :: List<String>%(is-link)) -> Number:
  1
where:
  doc1 = [list: "John", "likes", "to", "watch", "movies", "Mary", "likes", "to", "too"]
  doc2 = [list: "John", "also", "likes", "to", "watch", "football", "games"]
  doc3 = [list: "John", "john", "also", "likes", "to", "watch", "football", "games"]
  doc-different = [list: "nothing", "in", "common", "with", "either", "one"]
  doc-upper = map(string-toupper, doc1)

  overlap([list: "A"], [list: "a"]) is 1
  overlap(doc1, doc-upper) is 1
  overlap(doc1, doc2) is (6/13)
  overlap(doc2, doc1) is (6/13)
  overlap(doc1, doc3) is (7/13)
  overlap(doc1, doc1) is 1
  overlap(doc2, doc2) is 1
  overlap(doc1, doc-different) is 0
  overlap(doc2, doc-different) is 0
end
