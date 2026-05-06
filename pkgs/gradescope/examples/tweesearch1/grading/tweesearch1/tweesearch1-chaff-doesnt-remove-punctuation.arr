
provide: search end
# END HEADER
# chaff (gglass):
#   Doesn't filter out punctuation.
#    - Treats empty tweets as [list: ""];
#    - Does not raise error on invalid thesholds;
#    - Pyret built-in sort order.
#   Search "CHAFF DIFFERENCE" for changed code.


###############################
###### Utility Functions ######
###############################

fun count<A>(item :: A, lis :: List<A>) -> Number:
  doc: ```Finds the frequency of item in lis.```
  lis.foldl({(ele, acc): if ele == item: acc + 1 else: acc end}, 0)
end

fun sort-by-key<A>(lis :: List<A>, key :: (A -> Number)) -> List<A>:
  doc: ```Sorts a list by a key function.```
  lists.sort-by(
    lis,
    {(ele1, ele2): key(ele1) < key(ele2)},
    {(ele1, ele2): key(ele1) == key(ele2)})
end

###############################
###### DocDiff Functions ######
###############################

# Note that this is an adjusted version of docdiff! 
# Uses String instead of List<String>, split on space.
# And first strips all punctuation.
fun compare(doc1 :: String, doc2 :: String) -> Number:
  doc: ```Compares two docs for similarity by word frequency.
       Splits words by space.```
   
  # CHAFF DIFFERENCE: Doesn't get rid of punctuation or special characters
  prep = string-to-lower
  
  doc1-prepped = prep(doc1)
  doc2-prepped = prep(doc2)
  
  # Split by space
  words1 :: List<String> = string-split-all(doc1-prepped, " ")
  words2 :: List<String> = string-split-all(doc2-prepped, " ")
  
  # Get list of all unique words
  all-words :: List<String> = sets.list-to-set(words1)
    .union(sets.list-to-set(words2))
    .to-list()
  
  fun make-vector(words :: List<String>) -> List<Number>:
    doc: ```Makes a frequency vector.```
    all-words.map(count(_, words))
  end
  
  vector1 :: List<Number> = make-vector(words1)
  vector2 :: List<Number> = make-vector(words2)
  
  fun dot(v1 :: List<Number>, v2 :: List<Number>) -> Number:
    doc: ```Finds the dot product of two vectors.```
    fold2({(acc, ele1, ele2): acc + (ele1 * ele2)}, 0, v1, v2)
  end
  
  dot(vector1, vector2) / num-max(dot(vector1, vector1), dot(vector2, vector2))
end

###############################
#### TweeSearch Functions #####
###############################

fun relevance(current-tweet :: Tweet, search-tweet :: Tweet) -> Number:
  doc: ```Relevance function for tweet search.```
  compare(current-tweet.content, search-tweet.content)
end

fun search(
    search-tweet :: Tweet, 
    alot :: List<Tweet>, 
    threshold :: Number) 
  -> List<Tweet>:
  doc: ```Finds the most relevant tweets. Returns any with a relevance
       of at least threshold, sorted from most to least relevant.```
  
  # Sort and filter tweets by relevance
  sort-by-key(alot, relevance(_, search-tweet))
    .reverse() # Descending instead of ascending
    .filter({(t): relevance(t, search-tweet) >= threshold})
end
