
provide: anagram-reduce end
# END HEADER

#| chaff: anagram-reduce does not remove duplicates. |#

# CHAFF DIFFERENCE: returns input unchanged, no duplicate removal.
fun anagram-reduce(input :: Tv-pair<String, List<String>>) -> Tv-pair<String, List<String>>:
  input
end
