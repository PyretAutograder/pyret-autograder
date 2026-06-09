provide: overlap end
# END HEADER

# ---- reference implementation ----

fun overlap(doc1 :: List<String>, doc2 :: List<String>) -> Number:
  doc: "Finds the overlap value of two documents."

  doc1-lower :: List<String> = doc1.map(string-to-lower)
  doc2-lower :: List<String> = doc2.map(string-to-lower)

  unique-words :: List<String> = lists.distinct(doc1-lower + doc2-lower)

  fun make-vector(doc :: List<String>) -> List<Number>:
    doc: "Makes a vector of word frequencies for a given doc."
    for map(vec-word from unique-words):
      doc.filter({(doc-word): string-to-lower(doc-word) == string-to-lower(vec-word)})
         .length()
    end
  end

  vec1 :: List<Number> = make-vector(doc1-lower)
  vec2 :: List<Number> = make-vector(doc2-lower)

  fun dot-product(shadow vec1 :: List<Number>, shadow vec2 :: List<Number>) -> Number:
    doc: "Finds the dot product of two vectors."
    for fold2(sum from 0, count1 from vec1, count2 from vec2):
      sum + (count1 * count2)
    end
  end

  dot-product(vec1, vec2) / num-max(dot-product(vec1, vec1), dot-product(vec2, vec2))
end

# ---- fixtures ----

test_doc1 = [list: "John", "likes", "to", "watch", "movies", "Mary", "likes", "to", "too"]
test_doc2 = [list: "John", "also", "likes", "to", "watch", "football", "games"]
test_doc3 = [list: "Third", "in", "testing", "series", "watch", "it", "overlap", "with", "allofthem.", "football", "common"]
doc-different = [list: "nothing", "in", "common", "with", "either", "one"]
cats = [list: "The", "cat", "the", "cat"]
dogs = [list: "The", "dog", "the", "dog"]
the = [list: "the"]
the-2 = [list: "the", "the"]
empty-5 = [list: "", "", "", "", ""]
empty-2 = [list: "", ""]

# ---- tests ----

check "overlap":
  # completely different documents
  overlap(test_doc1, doc-different) is-roughly 0
  overlap(test_doc2, doc-different) is-roughly 0

  # identical documents
  overlap(test_doc1, test_doc1) is-roughly 1
  overlap(test_doc2, test_doc2) is-roughly 1

  # ignores capitalization
  overlap(cats, dogs) is-roughly 1/2
  overlap(dogs, cats) is-roughly 1/2

  # symmetry
  one-way = overlap(test_doc1, test_doc2)
  overlap(test_doc2, test_doc1) is-roughly one-way

  # deals with duplicates properly
  overlap(the-2, the) is-roughly 1/2
  overlap(the-2 + the, the) is-roughly 1/3

  # normal cases
  overlap(test_doc1, test_doc2) is-roughly (6/13)
  overlap(test_doc2, test_doc1) is-roughly (6/13)
  overlap(test_doc1, test_doc3) is-roughly (1/13)
  overlap(test_doc2, test_doc3) is-roughly (2/11)
  overlap(doc-different, test_doc3) is-roughly (3/11)
  overlap(empty-5, empty-2) is-roughly 2/5
end
