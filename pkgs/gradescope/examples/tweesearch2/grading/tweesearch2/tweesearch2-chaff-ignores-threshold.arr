use context essentials2021
include shared-gdrive("tweesearch2-definitions.arr", "196_3kepy6WuLKf5sQvzIW8kbZHkqzNwx")

provide: search end
# END HEADER
# chaff (tdelvecc): 
#   Threshold is ignored entirely (except when is 1 or more)
#    - Treats empty tweets as [list: ""];
#    - Does not raise error on invalid thresholds;
#    - Pyret built-in sorting order.
#   Search "CHAFF DIFFERENCE" for changed code.


###############################
###### Utility Functions ######
###############################

fun count<A>(item :: A, lis :: List<A>) -> Number:
  doc: ```Finds the frequency of item in lis.```
  lis.foldl({(ele, acc): if ele == item: acc + 1 else: acc end}, 0)
end

fun sort-by-key<A, B>(lis :: List<A>, key :: (A -> Number)) -> List<A>:
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

fun find-tweets-and-relevance(start-tweet :: Tweet, search-tweet :: Tweet) 
  -> List<Tv-pair<Tweet, Relevance>>:
  doc: ```Relevance function for tweet search.```

  fun helper(current-tweet :: Tweet) 
    -> List<Tv-pair<Tweet, Relevance>>:
    doc: ```Recurs on parent tweets; further away means less relevant.```

    # Find the docdiff similarity to current tweet
    similarity :: Number = compare(current-tweet.content, search-tweet.content)

    cases (Option<Tweet>) current-tweet.parent:
      | none => 
        # If there are no more parents, only use docdiff similarity
        link(tv-pair(current-tweet, similarity), empty)
      | some(parent) =>
        # If there are parents, find their relevance and recur
        ancestors :: List<Tv-pair<Tweet, Relevance>> = helper(parent)
        parent-relevance :: Relevance = 
          cases (List<Tv-pair<Tweet, Relevance>>) ancestors:
            | empty => raise("`helper` should never return empty list.")
            | link(f, _) => f.value
          end
        current-pair :: Tv-pair<Tweet, Relevance> = 
          tv-pair(current-tweet, 
            (0.75 * similarity) + (0.25 * parent-relevance))

        ancestors.push(current-pair)
    end
  end

  helper(start-tweet)
end

fun search(
    search-tweet :: Tweet, 
    alot :: List<Tweet>, 
    threshold :: Number) 
  -> List<Tweet>:
  doc: ```Finds the most relevant tweets. Returns any with a relevance
       of at least threshold, sorted from most to least relevant.```
  
  # Find all tweets and associated relevance
  all-tweets :: List<Tv-pair<Tweet, Relevance>> =
    for fold(tweets from empty, current-tweet from alot):
      tweets.append(find-tweets-and-relevance(current-tweet, search-tweet))
    end
  
  # Remove duplicates
  unique-tweets :: List<Tv-pair<Tweet, Relevance>> =
    for fold(unique-tweets from empty, current-tweet from all-tweets):
      if unique-tweets.any({(other-tweet :: Tv-pair<Tweet, Relevance>): 
            current-tweet.tag <=> other-tweet.tag}):
        unique-tweets
      else:
        link(current-tweet, unique-tweets)
      end
    end

  # Sort, filter, and extract tweets
  sort-by-key(unique-tweets, {(t :: Tv-pair<Tweet, Relevance>): t.value})
    .reverse() # Descending instead of ascending
  # CHAFF DIFFERENCE: Treats threshold as 0 if not at least 1
    .filter({(t :: Tv-pair<Tweet, Relevance>): 
      (threshold < 1) or (t.value >= threshold)})
    .map({(t :: Tv-pair<Tweet, Relevance>): t.tag})
end
