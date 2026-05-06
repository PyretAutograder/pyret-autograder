use context essentials2021
include shared-gdrive("tweesearch2-definitions.arr", "196_3kepy6WuLKf5sQvzIW8kbZHkqzNwx")

provide: search end
# END HEADER
# wheat (tdelvecc): 
#   Basic wheat; follows specs without additional features:
#    - Treats empty tweets as [list: ""];
#    - Does not raise error on invalid thresholds;
#    - Stable sort order of ties.


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
    .filter({(t :: Tv-pair<Tweet, Relevance>): t.value >= threshold})
    .map({(t :: Tv-pair<Tweet, Relevance>): t.tag})
end

###########################
########## TESTS ##########
###########################

#|
fun oracle(
    format :: List<List<String>>, 
    possibility :: List<String>)
  -> Boolean:
  doc: ```Checks if possibility is a valid solution based on format.
       Each List in format is an equivalence class.```
  # Check if no more format list left
  cases (List) format:
    | empty => is-empty(possibility)
    | link(format-f, format-r) =>
      # Check if no more possibility left
      cases (List) possibility:
        | empty => format.all(is-empty)
        | link(poss-f, poss-r) =>
          # Check if first element in format is empty
          cases (List) format-f:
            | empty => oracle(format-r, possibility)
            | link(_, _) =>
              format-f.member(poss-f)
              and oracle(
                link(format-f.remove(poss-f), format-r), 
                poss-r)
          end
      end
  end
where:
  oracle([list: [list: "A", "B", "C"], [list: "D", "E", "F"]],
    [list: "C", "B", "A", "E", "F", "D"]) is true
  oracle([list: empty, empty, [list: "A", "B"], [list: "C"], empty],
    [list: "B", "A", "C"]) is true

  oracle([list: [list: "A", "B"], [list: "C", "D"]],
    [list: "A", "C", "D"]) is false
  oracle([list: [list: "A", "B"], [list: "C", "D"]],
    [list: "A", "C", "B", "D"]) is false
  oracle([list: [list: "A", "B"], [list: "C", "D"]],
    [list: "A", "B", "B", "C", "D"]) is false 
end

check ```One tweet thread```:
  tweet1 = tweet("1", "Hello Bye", option.none)
  tweet2 = tweet("2", "Hello Nah", option.some(tweet1))
  tweet3 = tweet("3", "Hello Bye Bye", option.some(tweet2))
  tweet4 = tweet("4", "Hello Bye Hello", option.none)

  search(tweet4, [list: tweet3], 0.2)
    is [list: tweet3, tweet1, tweet2]
  search(tweet4, [list: tweet3], 0.5)
    is [list: tweet3, tweet1]
   end 

 check ```Basic test for functionality```:
  # 4 / 6 = 2 / 3
  tweet-a1 = tweet("a1", "A B C D", none)
  # ((2 / 6) * (3 / 4)) + ((4 / 6) * (1 / 4)) = 5 / 12
  tweet-a2 = tweet("a2", "B C D E", some(tweet-a1))
  # ((4 / 8) * (3 / 4)) + ((5 / 12) * (1 / 4)) = 23 / 48
  tweet-a3 = tweet("a3", "B B C C", some(tweet-a2))
  # 2 / 6 = 1 / 3
  tweet-a4 = tweet("a4", "C C D", some(tweet-a3))
  # 0 / 6 = 0 / 1
  tweet-b1 = tweet("b1", "D E F G H", none)
  # ((4 / 6) * (3 / 4)) + ((0 / 6) * (1 / 4)) = 1 / 2
  tweet-b2 = tweet("b2", "A A", some(tweet-b1))
  # 2 / 6 = 1 / 3
  tweet-c1 = tweet("c1", "B C D E", none)
  search-tweet = tweet("search", "A A B C", none)

  sol = search(
    search-tweet,
    [list: 
      tweet-a1, tweet-a2, tweet-a3, tweet-a4, 
      tweet-b1, tweet-b2, 
      tweet-c1],
    1 / 6)

  sol satisfies oracle([list: 
      [list: tweet-a1], 
      [list: tweet-b2], 
      [list: tweet-a3],
      [list: tweet-a2],
      [list: tweet-a4, tweet-c1]],
    _)
   end
|#
