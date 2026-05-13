
provide: anagram-map end
# END HEADER

#| chaff: anagram-map lowercases words before alphabetizing, treating
    differently-cased anagrams as equal. |#

# CHAFF DIFFERENCE: lowercases words before alphabetizing.
fun anagram-map(input :: Tv-pair<String, String>) -> List<Tv-pair<String, String>>:
  map({(word): tv(alphabetize(string-tolower(word)), word)}, parse(input.value, " "))
end
