#|
    DOES NOT obey:
        Overlap of two documents must be proportional to the dot product of the documents
    Instead: Returns an overlap of 1 if one document is subsumed by another.

    NOTE: In the source this bug lived in a `overlap-wrapped` that the module
    re-exported as `overlap`.  Because the autograder merges alternate
    implementations by top-level function NAME (not by what the module
    re-exports), the bug is inlined directly into `overlap` here, with the
    correct computation moved into the helper `overlap-rec`.
|#

fun check-subsumption(smaller :: List<String>, larger :: List<String>):
  if smaller == empty:
    true
  else:
    # Ensure that all the elements of smaller are in larger
    smaller.all(lam(w): larger.member(w) end) and check-subsumption(smaller.drop(1), larger.drop(1))
  end
end

fun overlap(doc1 :: List<String>%(is-link), doc2 :: List<String>%(is-link)) -> Number:
  if (doc1.length() > doc2.length()) and check-subsumption(doc2, doc1):
    1
  else if check-subsumption(doc1, doc2):
    1
  else:
    overlap-rec(doc1, doc2)
  end
end

fun overlap-rec(doc1 :: List<String>%(is-link), doc2 :: List<String>%(is-link)) -> Number:
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
