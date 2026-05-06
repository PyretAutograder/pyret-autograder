
provide: search end
# END HEADER
#| wheat (tdelvecc, Aug 31, 2020): 
    - Raises error on empty tweet;
    - Raises error on invalid thesholds;
    - Reverse stable sort order of ties.
    Seach "WHEAT DIFFERENCE" for changed code.
|#


###############################
###### Utility Functions ######
###############################

fun count<A>(item :: A, lis :: List<A>) -> Number:
  doc: ```Finds the frequency of item in lis.```
  lis.foldl({(ele, acc): if ele == item: acc + 1 else: acc end}, 0)
  #|
where:
  count("A", empty) is 0
  count("A", [list: "A"]) is 1
  count("A", [list: "B", "A", "C"]) is 1
  count("A", [list: "B", "A", "C", "A", "A"]) is 3
  count("A", [list: "B", "C", "D"]) is 0
  |#
end

# Note that this is used here so that another wheat can
# change the output order for ties.
fun stable-sort-by<A>(
    lis :: List<A>, 
    lt :: (A, A -> Boolean), 
    eq :: (A, A -> Boolean)) 
  -> List<A>:
  doc: ```Sorts stably... why doesn't Pyret do this?```
  cases (List) lis:
    | empty => lis
    | link(f, r) =>
      pivot = f
      lt-list = r.filter(lt(_, pivot))
      eq-list = r.filter(eq(_, pivot))
      gt-list = r.filter(lt(pivot, _))

      stable-sort-by(lt-list, lt, eq)
        .append(link(f, eq-list)
          .append(stable-sort-by(gt-list, lt, eq)))
  end
end

fun sort-by-key<A>(lis :: List<A>, key :: (A -> Number)) -> List<A>:
  doc: ```Sorts a list by a key function.```
  stable-sort-by(
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
fun compare(doc1 :: String, doc2 :: String) -> Number block:
  doc: ```Compares two docs for similarity by word frequency.
       Splits words by space.```
  
  # WHEAT DIFFERENCE: Raises an error when doc1 or doc2 empty.
  when (doc1 == "") or (doc2 == ""):
    raise("Can't compare an empty document!")
  end
  
  # Convert to lower and filter so only alphanumeric+space
  alphanumspace = " abcdefghijklmnopqrstuvwxyz1234567890"
  
  prep = lam(doc): string-explode(string-to-lower(doc)).filter(
    lam(x): string-contains(alphanumspace, x) end).join-str("") end
  
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
  #|
where:
  compare("Hi", "Bye") is 0
  compare("Hi", "Hi") is 1
  compare("Hi Bye", "Bye Hi") is 1
  compare("Hi Bye", "Bye Hello") is 0.5
  compare("Hi Bye", "Hi") is 0.5
  compare("Hi Hi Bye Bye Yo", "Hi Bye Me") is 4 / 9
  compare("Hi Hi Hi", "Hi Hi Bye") is 6 / 9
  compare("hi", "HI") is 1
  |#
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
  -> List<Tweet> block:
  doc: ```Finds the most relevant tweets. Returns any with a relevance
       of at least threshold, sorted from most to least relevant.```
  
  # WHEAT DIFFERENCE: Raises an error when threshold outside of range [0, 1].
  when not((0 <= threshold) and (threshold <= 1)):
    raise("Threshold not valid!")
  end
  
  # Sort and filter tweets by relevance
  # WHEAT DIFFERENCE: Sort revere stably by reversing before sorting.
  sort-by-key(alot.reverse(), relevance(_, search-tweet))
    .reverse() # Descending instead of ascending
    .filter({(t): relevance(t, search-tweet) >= threshold})
end

###########################
########## TESTS ##########
###########################

#|
check ```Basic test for functionality```:
  compare(
    "Instead of taking the crate, say \"It's far too heavy to lift.\"",
    "Instead of taking the crate, say \"It's far too heavy to lift.\"") is 1
end

check ```Empty list of tweets should return empty```:
  search(tweet("", "content"), empty, 0) is empty
end

check ```Threshold of 1 should only include exact match on content```:
  tweet-a = tweet("1", "A")
  tweet-b = tweet("2", "B")
  tweet-c = tweet("3", "C")
  search-tweet = tweet("", "A")
  
  sol = search(
    search-tweet, 
    [list: tweet-a, tweet-b, tweet-c],
    1)

  sol is [list: tweet-a]
end

check ```Threshold of 0 should include everything```:
  tweet-a = tweet("1", "A")
  tweet-b = tweet("2", "B")
  tweet-c = tweet("3", "C")
  search-tweet = tweet("", "A")
  
  sol = search(
    search-tweet, 
    [list: tweet-a, tweet-b, tweet-c],
    0)
  
  sol.first is tweet-a
  sol.member(tweet-b) is true
  sol.member(tweet-c) is true
  sol.length() is 3
end
|#
