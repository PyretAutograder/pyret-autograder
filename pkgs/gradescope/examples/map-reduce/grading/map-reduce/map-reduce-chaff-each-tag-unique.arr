
provide: anagram-map end
# END HEADER

#| chaff: anagram-map uses the word itself as the tag instead of its
    alphabetized form, so anagrams get different tags. |#

# CHAFF DIFFERENCE: uses word as its own tag instead of alphabetized form.
fun anagram-map(input :: Tv-pair<String, String>) -> List<Tv-pair<String, String>>:
  map({(word): tv(word, word)}, parse(input.value, " "))
end
