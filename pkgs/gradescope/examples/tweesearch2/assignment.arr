provide: search end
# END HEADER

include file("submission/assignment-support.arr")

# Bare (non-method) list functions used by some grading implementations.
# Only the non-global ones are imported, to avoid shadowing the builtins
# `map`/`filter`.
import append, reverse, foldl, sort-by, member-identical from lists
import list-to-set from sets

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
  all-words :: List<String> = list-to-set(words1)
    .union(list-to-set(words2))
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


# Test helper: checks a result respects relevance ordering while allowing
# any order within a tie (equivalence) class.
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
  #|
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
  |#
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
where:
  none-st = tweet("search", "A", none)
  # empty list -> empty
  search(none-st, empty, 0) is empty
  # threshold inclusive at 1: relevance exactly 1 is kept
  search(none-st, [list: tweet("1", "A", none)], 1) is [list: tweet("1", "A", none)]
  # threshold inclusive at 0.5: relevance exactly 0.5 is kept
  # (catches an off-by-epsilon exclusive threshold)
  search(tweet("search", "A", none), [list: tweet("1", "A B", none)], 0.5)
    is [list: tweet("1", "A B", none)]
  # case-insensitive: lowercase "a" still matches "A"
  search(none-st, [list: tweet("1", "a", none)], 1) is [list: tweet("1", "a", none)]
  # punctuation stripped: "A!" still matches "A"
  search(none-st, [list: tweet("1", "A!", none)], 1) is [list: tweet("1", "A!", none)]
  # extra spaces are significant: "A B" vs "A  B" -> relevance 2/3, below 0.9
  search(tweet("search", "A B", none), [list: tweet("1", "A  B", none)], 0.9) is empty
  # threshold filters out low relevance
  search(tweet("search", "A B", none),
    [list: tweet("1", "A B", none), tweet("2", "C", none)], 0.5)
    is [list: tweet("1", "A B", none)]
  # results sorted from most to least relevant
  search(tweet("search", "A B", none),
    [list: tweet("2", "A", none), tweet("1", "A B", none)], 0)
    is [list: tweet("1", "A B", none), tweet("2", "A", none)]

  # parent chains: searching a tweet returns it and all its ancestors,
  # sorted by relevance (parent relevance discounted).  All relevances here
  # are distinct, so the order is determined.
  block:
    tweet-a1 = tweet("a1", "A B C D", none)        # 0.666
    tweet-a2 = tweet("a2", "B C D E", some(tweet-a1)) # 0.416
    tweet-a3 = tweet("a3", "B B C C", some(tweet-a2)) # 0.479
    tweet-a4 = tweet("a4", "C C D", some(tweet-a3))   # 0.369
    tweet-b1 = tweet("b1", "D E F G H", none)      # 0.000
    tweet-b2 = tweet("b2", "A A", some(tweet-b1))     # 0.500
    tweet-c1 = tweet("c1", "B C D E", none)        # 0.333
    s = tweet("search", "A A B C", none)
    search(s, [list: tweet-a4, tweet-b2, tweet-c1], 1 / 6)
      is [list: tweet-a1, tweet-b2, tweet-a3, tweet-a2, tweet-a4, tweet-c1]
  end

  # duplicates: a tweet reachable via the list AND as an ancestor appears once
  block:
    tweet-a1 = tweet("a1", "A B C D", none)
    tweet-a2 = tweet("a2", "B C D E", some(tweet-a1))
    tweet-a3 = tweet("a3", "B B C C", some(tweet-a2))
    tweet-a4 = tweet("a4", "C C D", some(tweet-a3))
    tweet-b1 = tweet("b1", "D E F G H", none)
    tweet-b2 = tweet("b2", "A A", some(tweet-b1))
    tweet-c1 = tweet("c1", "B C D E", none)
    s = tweet("search", "A A B C", none)
    search(s,
      [list: tweet-a1, tweet-a2, tweet-a3, tweet-a4, tweet-b1, tweet-b2, tweet-c1],
      1 / 6)
      is [list: tweet-a1, tweet-b2, tweet-a3, tweet-a2, tweet-a4, tweet-c1]
  end

  # uniqueness is by identity, not by structural equality: distinct tweets
  # that happen to be structurally equal (a shallow copy) are NOT merged.
  block:
    fun copy-tweet(t :: Tweet) -> Tweet: tweet(t.author, t.content, t.parent) end
    tweet-a1 = tweet("a1", "A B C D", none)
    tweet-a2 = tweet("a2", "B C D E", some(copy-tweet(tweet-a1)))
    tweet-a3 = tweet("a3", "B B C C", some(copy-tweet(tweet-a2)))
    tweet-a4 = tweet("a4", "C C D", some(copy-tweet(tweet-a3)))
    tweet-b1 = tweet("b1", "D E F G H", none)
    tweet-b2 = tweet("b2", "A A", some(copy-tweet(tweet-b1)))
    tweet-c1 = tweet("c1", "B C D E", none)
    s = tweet("search", "A A B C", none)
    search(s,
      [list: tweet-a1, tweet-a2, tweet-a3, tweet-a4, tweet-b1, tweet-b2, tweet-c1],
      1 / 6)
      is [list: tweet-a1, tweet-a1, tweet-b2, tweet-a3, tweet-a3,
        tweet-a2, tweet-a2, tweet-a4, tweet-c1]
  end

  # ties: equally-relevant tweets all appear, any order within the tie class
  block:
    tweet-a1 = tweet("a1", "A", none)
    tweet-a2 = tweet("a2", "A", some(tweet-a1))
    tweet-b1 = tweet("b1", "A", none)
    s = tweet("search", "A", none)
    search(s, [list: tweet-a2, tweet-b1], 1)
      satisfies oracle([list: [list: tweet-a1, tweet-a2, tweet-b1]], _)
  end
end
