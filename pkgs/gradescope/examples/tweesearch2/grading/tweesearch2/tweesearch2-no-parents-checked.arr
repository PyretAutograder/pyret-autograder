use context essentials2021
include shared-gdrive("tweesearch2-definitions.arr", "196_3kepy6WuLKf5sQvzIW8kbZHkqzNwx")

provide: search end
# END HEADER
# chaff (tdelvecc): 
#   Threshold is treated as exclusive when 0 < threshold < 1
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

fun relevance(search-tweet-words :: List<String>, old-tweet :: Tweet) -> Number:
  doc: ```computes the relevance of old-tweet based on overlap
       and the relevance of old-tweet's parent```
  old-tweet-overlap = overlap(search-tweet-words, tweet-to-list(old-tweet))
  cases (Option) old-tweet.parent:
    | none => old-tweet-overlap
    | some(t) =>
      (old-tweet-overlap * 0.75) + (relevance(search-tweet-words, t) * 0.25)
  end
end

fun tweet-to-list(t :: Tweet) -> List<String>:
  doc: ```converts a tweet into a list of strings representing "words"
       removes non-alphanumeric characters and converts all to lowercase```
  lowercase-tweet = string-to-lower(t.content)
  tweet-code-points = string-to-code-points(lowercase-tweet)
  tweet-alphanumeric = filter(
    lam(n): (n == 32) or ((n >= 48) and (n <= 57)) or ((n >= 97) and (n <= 122))
    end, tweet-code-points)
  code-points-to-words(tweet-alphanumeric)
end

fun code-points-to-words(code-points :: List<Number>) -> List<String>:
  doc: "turns a list of code points into a list of strings representing words"
  cases (List) code-points:
    | empty => [list: string-from-code-points(empty)]
    | link(f, r) =>
      if code-points.member(32):
        {f-word-points; r-code-points} = first-word(code-points)
        f-word = string-from-code-points(f-word-points)
        link(f-word, code-points-to-words(r-code-points))
      else:
        word = string-from-code-points(code-points)
        [list: word]
      end
  end
end

fun first-word(code-points :: List<Number>) -> {List<Number>; List<Number>}:
  doc: ```returns the code points up to (but not including) the first space
       and the rest of the code points (after the space)```
  cases (List) code-points:
    | empty => {empty; empty}
    | link(f, r) =>
      if f == 32:
        {empty; r}
      else:
        {r-word; r-code-points} = first-word(r)
        {link(f, r-word); r-code-points}
      end
  end
end

fun overlap(doc1 :: List<String>, doc2 :: List<String>) -> Number:
  doc: "computes the overlap of two documents"
  all-words = unique(append(doc1, doc2))
  vector1 = map(lam(word): count-instances(word, doc1) end, all-words)
  vector2 = map(lam(word): count-instances(word, doc2) end, all-words)
  denominator =
    if dot-product(vector1, vector1) > dot-product(vector2, vector2):
      dot-product(vector1, vector1)
    else:
      dot-product(vector2, vector2)
    end
  dot-product(vector1, vector2) / denominator
end

fun dot-product(v1 :: List<Number>, v2 :: List<Number>) -> Number:
  doc: "returns the dot product of two vectors of the same length"
  fold2(lam(total, n1, n2): total + (n1 * n2) end, 0, v1, v2)
  #|where:
  dot-product(empty, empty) is 0
  dot-product([list: 1, 1, 1, 0], [list: 0, 1, 0, 3]) is 1
  dot-product([list: 3, 4, 1, 0], [list: 1, 2, 1, 3]) is 12|#
end

fun unique<T>(alot :: List<T>) -> List<T>:
  doc: "remove all duplicate values in alot"
  reverse(foldl(lam(l, t): if l.member(t): l else: link(t, l) end end,
      empty, alot))
  #|where:
  unique(empty) is empty
  unique([list: "hi", "no"]) is [list: "hi", "no"]
  unique([list: "hi", "hi", "3", "3", "hi", 10]) is [list: "hi", "3", 10]
  unique([list: "hey", "no", "no", 4, 16, 4]) is [list: "hey", "no", 4, 16]|#
end

fun unique-identical<T>(alot :: List<T>) -> List<T>:
  doc: "remove all duplicate values in alot comparing with identical"
  reverse(foldl(lam(l, t): if member-identical(l, t): l else: link(t, l) end end,
      empty, alot))
  #|where:
  unique-identical(empty) is empty
  unique-identical([list: "hi", "no"]) is [list: "hi", "no"]
  unique-identical([list: "hi", "hi", "3", "3", "hi", 10])
    is [list: "hi", "3", 10]
  unique-identical([list: "hey", "no", "no", 4, 16, 4])
    is [list: "hey", "no", 4, 16]
  tweet1 = tweet("Bob", "hi", none)
  tweet2 = tweet("Rob", "hey", some(tweet1))
  tweet3 = tweet1
  tweet4 = tweet("Rob", "hey", some(tweet1))
  unique-identical([list: tweet1, tweet2, tweet3, tweet4, tweet3])
    is [list: tweet1, tweet2, tweet4]|#
end

fun count-instances<T>(t :: T, alot :: List<T>) -> Number:
  doc: "counts how many times t appears in alot"
  foldl(lam(n, elt): if elt == t: n + 1 else: n end end, 0, alot)
  #|where:
  count-instances("hi", empty) is 0
  count-instances("hi", [list: "a", "b", "c"]) is 0
  count-instances("hi", [list: "hi", "bye", "hi", "hi", "bye"]) is 3
  count-instances("a", [list: "a", "a", "b", "c"]) is 2|#
end

fun search(
    search-tweet :: Tweet, 
    alot :: List<Tweet>, 
    threshold :: Number) 
  -> List<Tweet>:
  doc: ```Finds the most relevant tweets. Returns any with a relevance
       of at least threshold, sorted from most to least relevant.```
  search-tweet-words = tweet-to-list(search-tweet)
  relevant-tweets = filter(lam(tweet1):
    relevance(search-tweet-words, tweet1) >= threshold end, alot)
  sorted-tweets = sort-by(relevant-tweets, lam(tweet1, tweet2):
      relevance(search-tweet-words, tweet1)
      > relevance(search-tweet-words, tweet2) end,
    lam(tweet1, tweet2): relevance(search-tweet-words, tweet1)
      == relevance(search-tweet-words, tweet2) end)
  unique-identical(sorted-tweets)
end
