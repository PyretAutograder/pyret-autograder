
provide: search end
# END HEADER
# chaff (tdelvecc): 
#   Nodes don't count themselves in the size of their subtree.
#    - Treats empty tweets as [list: ""];
#    - Does not raise error on invalid thresholds;
#    - Builtin Pyret sort order.
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
end

###############################
#### TweeSearch Functions #####
###############################

data Tv-pair<A, B>:
  | tv-pair(tag :: A, value :: B)
end

type Relevance = Number

fun find-size(current-tweet :: Tweet) -> Number:
  doc: ```Finds the size of a tweet tree.```
  
  # CHAFF DIFFERENCE: Subtracts one from the size of subtree
  #                   (unless it's a unit to avoid divide by 0).
  fun helper(shadow current-tweet :: Tweet) -> Number: 
    current-tweet.children.foldl({(t, acc): helper(t) + acc}, 1)
  end
  
  num-max(helper(current-tweet) - 1, 1)
end

fun find-tweets-and-relevance(
    start-tweet :: Tweet, 
    search-tweet :: Tweet, 
    total-tweets :: Number) 
  -> List<Tv-pair<Tweet, Relevance>>:
  doc: ```Relevance function for tweet search.```

  fun helper(
      current-tweet :: Tweet, 
      parent-relevance :: Option<Relevance>) 
    -> List<Tv-pair<Tweet, Relevance>>:
    doc: ```Calculate relevance and recur on children tweets.```

    # Find the docdiff similarity to current tweet
    similarity :: Number = compare(current-tweet.content, search-tweet.content)

    # Find the relevance of the current tweet
    current-relevance :: Relevance = 
      cases (Option) parent-relevance:
        | none => 
          (0.75 * similarity)
            + (0.25 * (find-size(current-tweet) / total-tweets))
        | some(parent-rel) => 
          (0.60 * similarity) 
            + (0.20 * parent-rel) 
            + (0.20 * (find-size(current-tweet) / total-tweets))
      end

    # Recur to find the relevance of the children (and descendent) tweets
    children :: List<Tv-pair<Tweet, Relevance>> =
      current-tweet.children
      .map(helper(_, some(current-relevance)))
      .foldl(lists.append, empty)

    # Add current tweet to children and return
    children.push(tv-pair(current-tweet, current-relevance))
  end

  helper(start-tweet, none)
end

fun search(
    search-tweet :: Tweet, 
    alot :: List<Tweet>, 
    threshold :: Number) 
  -> List<Tweet>:
  doc: ```Finds the most relevant tweets. Returns any with a relevance
       of at least threshold, sorted from most to least relevant.```

  # Find the total number of tweets in alot (and associated trees)
  total-tweets :: Number = alot.map(find-size).foldl(_ + _, 0)

  # Find all tweets and associated relevance
  all-tweets :: List<Tv-pair<Tweet, Relevance>> =
    for fold(tweets from empty, current-tweet from alot):
      tweets.append(
        find-tweets-and-relevance(current-tweet, search-tweet, total-tweets))
    end

  # Sort, filter, and extract tweets
  sort-by-key(all-tweets, {(t :: Tv-pair<Tweet, Relevance>): t.value})
    .reverse() # Descending instead of ascending
    .filter({(t :: Tv-pair<Tweet, Relevance>): t.value >= threshold})
    .map({(t :: Tv-pair<Tweet, Relevance>): t.tag})
end
