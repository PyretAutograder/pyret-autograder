provide: search end

include file("submission/assignment-support.arr")


###############################
###### Utility Functions ######
###############################

fun count<A>(item :: A, lis :: List<A>) -> Number:
  doc: ```Finds the frequency of item in lis.```
  lis.foldl({(ele, acc): if ele == item: acc + 1 else: acc end}, 0)
  where:
    1 is 1 # bogus test. This is not exported. However, a whaff can replace it.
end

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
  where:
    1 is 1 # bogus test. This is not exported. However, a whaff can replace it.
end

fun sort-by-key<A>(lis :: List<A>, key :: (A -> Number)) -> List<A>:
  doc: ```Sorts a list by a key function.```
  stable-sort-by(
    lis,
    {(ele1, ele2): key(ele1) < key(ele2)},
    {(ele1, ele2): key(ele1) == key(ele2)})
  where:
    1 is 1 # bogus test. This is not exported. However, a whaff can replace it.
end

###############################
###### DocDiff Functions ######
###############################

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
  where:
    1 is 1 # bogus test. This is not exported. However, a whaff can replace it.
end

###############################
#### TweeSearch Functions #####
###############################

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
  where:
    1 is 1 # bogus test. This is not exported. However, a whaff can replace it.
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
  # "Basic test for functionality"
  block:
    # 2 / 3 = 0.666 = 4 / 6
    tweet-a1 = tweet("a1", "A B C D", none)
    # 5 / 12 = 0.416 = ((2 / 6) * (3 / 4)) + ((4 / 6) * (1 / 4))
    tweet-a2 = tweet("a2", "B C D E", some(tweet-a1))
    # 23 / 48 = 0.479 = ((4 / 8) * (3 / 4)) + ((5 / 12) * (1 / 4))
    tweet-a3 = tweet("a3", "B B C C", some(tweet-a2))
    # 71 / 192 = 0.369 = ((2 / 6) * (3 / 4)) + ((23 / 48) * (1 / 4))
    tweet-a4 = tweet("a4", "C C D", some(tweet-a3))
    # 0 / 1 = 0.000 = 0 / 6
    tweet-b1 = tweet("b1", "D E F G H", none)
    # 1 / 2 = 0.500 = ((4 / 6) * (3 / 4)) + ((0 / 6) * (1 / 4))
    tweet-b2 = tweet("b2", "A A", some(tweet-b1))
    # 1 / 3 = 0.333 = 2 / 6
    tweet-c1 = tweet("c1", "B C D E", none)
    search-tweet-t = tweet("search", "A A B C", none)

    sol = search(
      search-tweet-t,
      [list: tweet-a4, tweet-b2, tweet-c1],
      1 / 6)

    sol is [list: tweet-a1, tweet-b2, tweet-a3, tweet-a2, tweet-a4, tweet-c1]
  end

  # "Dealing with duplicates"
  block:
    # 2 / 3 = 0.666 = 4 / 6
    tweet-a1 = tweet("a1", "A B C D", none)
    # 5 / 12 = 0.416 = ((2 / 6) * (3 / 4)) + ((4 / 6) * (1 / 4))
    tweet-a2 = tweet("a2", "B C D E", some(tweet-a1))
    # 23 / 48 = 0.479 = ((4 / 8) * (3 / 4)) + ((5 / 12) * (1 / 4))
    tweet-a3 = tweet("a3", "B B C C", some(tweet-a2))
    # 71 / 192 = 0.369 = ((2 / 6) * (3 / 4)) + ((23 / 48) * (1 / 4))
    tweet-a4 = tweet("a4", "C C D", some(tweet-a3))
    # 0 / 1 = 0.000 = 0 / 6
    tweet-b1 = tweet("b1", "D E F G H", none)
    # 1 / 2 = 0.500 = ((4 / 6) * (3 / 4)) + ((0 / 6) * (1 / 4))
    tweet-b2 = tweet("b2", "A A", some(tweet-b1))
    # 1 / 3 = 0.333 = 2 / 6
    tweet-c1 = tweet("c1", "B C D E", none)
    search-tweet-t = tweet("search", "A A B C", none)

    sol = search(
      search-tweet-t,
      [list: tweet-a1, tweet-a2, tweet-a3, tweet-a4,
        tweet-b1, tweet-b2,
        tweet-c1],
      1 / 6)

    sol is [list: tweet-a1, tweet-b2, tweet-a3, tweet-a2, tweet-a4, tweet-c1]
  end

  # "Two tweets share a parent"
  block:
    # 2 / 3 = 0.666 = 4 / 6
    tweet-a1 = tweet("a1", "A B C D", none)
    # 5 / 12 = 0.416 = ((2 / 6) * (3 / 4)) + ((4 / 6) * (1 / 4))
    tweet-a21 = tweet("a21", "B C D E", some(tweet-a1))
    # 23 / 48 = 0.479 = ((4 / 8) * (3 / 4)) + ((5 / 12) * (1 / 4))
    tweet-a31 = tweet("a31", "B B C C", some(tweet-a21))
    # 71 / 192 = 0.369 = ((2 / 6) * (3 / 4)) + ((23 / 48) * (1 / 4))
    tweet-a41 = tweet("a41", "C C D", some(tweet-a31))
    # 7 / 24 = 0.291 = ((1 / 6) * (3 / 4)) + ((2 / 3) * (1 / 4))
    tweet-a22 = tweet("a22", "C D F G", some(tweet-a1))
    # 43 / 96 = 0.447 = ((5 / 10) * (3 / 4)) + ((7 / 24) * (1 / 4))
    tweet-a32 = tweet("a32", "A B B B", some(tweet-a22))
    # 91 / 384 = 0.236 = ((1 / 6) * (3 / 4)) + ((43 / 96) * (1 / 4))
    tweet-a42 = tweet("a42", "C D", some(tweet-a32))
    # 0 / 1 = 0.000 = 0 / 6
    tweet-b1 = tweet("b1", "D E F G H", none)
    # 1 / 2 = 0.500 = ((4 / 6) * (3 / 4)) + ((0 / 6) * (1 / 4))
    tweet-b2 = tweet("b2", "A A", some(tweet-b1))
    # 1 / 3 = 0.333 = 2 / 6
    tweet-c1 = tweet("c1", "B C D E", none)
    search-tweet-t = tweet("search", "A A B C", none)

    sol = search(
      search-tweet-t,
      [list: tweet-a41, tweet-a42, tweet-b2, tweet-c1],
      1 / 6)

    sol is [list:
      tweet-a1,
      tweet-b2,
      tweet-a31,
      tweet-a32,
      tweet-a21,
      tweet-a41,
      tweet-c1,
      tweet-a22,
      tweet-a42]
  end

  # "Uniqueness is case-sensitive"
  block:
    # 2 / 3 = 0.666 = 4 / 6
    tweet-a1 = tweet("a1", "A B C D", none)
    # 5 / 12 = 0.416 = ((2 / 6) * (3 / 4)) + ((4 / 6) * (1 / 4))
    tweet-a2 = tweet("a2", "B C D E", some(tweet-a1))
    # 23 / 48 = 0.479 = ((4 / 8) * (3 / 4)) + ((5 / 12) * (1 / 4))
    tweet-a3 = tweet("a3", "B B C C", some(tweet-a2))
    # 1 / 3 = 0.333 = 2 / 6
    tweet-a4 = tweet("a4", "C C D", some(tweet-a3))
    tweet-b1 = tweet("b1", "a B c D", none)
    tweet-b2 = tweet("b2", "b C d E", some(tweet-b1))
    tweet-b3 = tweet("b3", "b B c C", some(tweet-b2))
    tweet-b4 = tweet("b4", "c C d", some(tweet-b3))
    tweet-c1 = tweet("c1", "A b C d", none)
    tweet-c2 = tweet("c2", "B c D e", some(tweet-c1))
    tweet-c3 = tweet("c3", "B b C c", some(tweet-c2))
    tweet-c4 = tweet("c4", "C c D", some(tweet-c3))
    search-tweet-t = tweet("search", "A A B C", none)

    sol = search(
      search-tweet-t,
      [list: tweet-a4, tweet-b4, tweet-c4],
      1 / 6)

    sol satisfies oracle([list:
        [list: tweet-a1, tweet-b1, tweet-c1],
        [list: tweet-a3, tweet-b3, tweet-c3],
        [list: tweet-a2, tweet-b2, tweet-c2],
        [list: tweet-a4, tweet-b4, tweet-c4]],
      _)
  end

  # "Checks uniqueness by identical, not equal-always"
  block:
    fun copy-tweet(t :: Tweet) -> Tweet:
      doc: ```Makes a shallow copy of a tweet.```
      tweet(t.author, t.content, t.parent)
    end

    # 2 / 3 = 0.666 = 4 / 6
    tweet-a1 = tweet("a1", "A B C D", none)
    # 5 / 12 = 0.416 = ((2 / 6) * (3 / 4)) + ((4 / 6) * (1 / 4))
    tweet-a2 = tweet("a2", "B C D E", some(copy-tweet(tweet-a1)))
    # 23 / 48 = 0.479 = ((4 / 8) * (3 / 4)) + ((5 / 12) * (1 / 4))
    tweet-a3 = tweet("a3", "B B C C", some(copy-tweet(tweet-a2)))
    # 71 / 192 = 0.369 = ((2 / 6) * (3 / 4)) + ((23 / 48) * (1 / 4))
    tweet-a4 = tweet("a4", "C C D", some(copy-tweet(tweet-a3)))
    # 0 / 1 = 0.000 = 0 / 6
    tweet-b1 = tweet("b1", "D E F G H", none)
    # 1 / 2 = 0.500 = ((4 / 6) * (3 / 4)) + ((0 / 6) * (1 / 4))
    tweet-b2 = tweet("b2", "A A", some(copy-tweet(tweet-b1)))
    # 1 / 3 = 0.333 = 2 / 6
    tweet-c1 = tweet("c1", "B C D E", none)
    search-tweet-t = tweet("search", "A A B C", none)

    sol = search(
      search-tweet-t,
      [list: tweet-a1, tweet-a2, tweet-a3, tweet-a4,
        tweet-b1, tweet-b2,
        tweet-c1],
      1 / 6)

    sol is [list: tweet-a1, tweet-a1, tweet-b2, tweet-a3, tweet-a3,
      tweet-a2, tweet-a2, tweet-a4, tweet-c1]
  end

  # "Empty list of tweets should return empty"
  search(tweet("empty", "content", none), empty, 0) is empty

  # "Threshold of 1 should only include exact match on content"
  block:
    tweet-a1 = tweet("a1", "A", none)
    tweet-a2 = tweet("a2", "A", some(tweet-a1))
    tweet-a3 = tweet("a3", "B", some(tweet-a2))
    tweet-b1 = tweet("b1", "A", none)
    tweet-b2 = tweet("b2", "B", some(tweet-b1))
    tweet-b3 = tweet("b3", "A", some(tweet-b2))
    search-tweet-t = tweet("search", "A", none)

    sol = search(
      search-tweet-t,
      [list: tweet-a3, tweet-b3],
      1)

    sol satisfies oracle([list:
        [list: tweet-a1, tweet-a2, tweet-b1]],
      _)
  end

  # "Threshold of 0 should include everything"
  block:
    # 2 / 3 = 0.666 = 4 / 6
    tweet-a1 = tweet("a1", "A B C D", none)
    # 5 / 12 = 0.416 = ((2 / 6) * (3 / 4)) + ((4 / 6) * (1 / 4))
    tweet-a2 = tweet("a2", "B C D E", some(tweet-a1))
    # 23 / 48 = 0.479 = ((4 / 8) * (3 / 4)) + ((5 / 12) * (1 / 4))
    tweet-a3 = tweet("a3", "B B C C", some(tweet-a2))
    # 71 / 192 = 0.369 = ((2 / 6) * (3 / 4)) + ((23 / 48) * (1 / 4))
    tweet-a4 = tweet("a4", "C C D", some(tweet-a3))
    # 0 / 1 = 0.000 = 0 / 6
    tweet-b1 = tweet("b1", "D E F G H", none)
    # 1 / 2 = 0.500 = ((4 / 6) * (3 / 4)) + ((0 / 6) * (1 / 4))
    tweet-b2 = tweet("b2", "A A", some(tweet-b1))
    # 1 / 3 = 0.333 = 2 / 6
    tweet-c1 = tweet("c1", "B C D E", none)
    search-tweet-t = tweet("search", "A A B C", none)

    sol = search(
      search-tweet-t,
      [list: tweet-a4, tweet-b2, tweet-c1],
      0)

    sol is [list: tweet-a1, tweet-b2, tweet-a3,
      tweet-a2, tweet-a4, tweet-c1, tweet-b1]
  end

  # "All tweets are tied"
  block:
    tweet-a1 = tweet("a1", "A", none)
    tweet-a2 = tweet("a2", "A", some(tweet-a1))
    tweet-a3 = tweet("a3", "A", some(tweet-a2))
    tweet-b1 = tweet("b1", "A", none)
    tweet-b2 = tweet("b2", "A", some(tweet-b1))
    tweet-b3 = tweet("b3", "A", some(tweet-b2))
    search-tweet-t = tweet("search", "A B", none)

    sol = search(
      search-tweet-t,
      [list: tweet-a3, tweet-b3],
      1 / 4)

    sol satisfies oracle([list:
        [list:
          tweet-a1, tweet-a2, tweet-a3,
          tweet-b1, tweet-b2, tweet-b3]],
      _)
  end

  # "All tweets 0 relevance"
  block:
    tweet-a1 = tweet("a1", "A B C D", none)
    tweet-a2 = tweet("a2", "B C D E", some(tweet-a1))
    tweet-a3 = tweet("a3", "B B C C", some(tweet-a2))
    tweet-b1 = tweet("b1", "C C D", none)
    tweet-b2 = tweet("b2", "D E F G H", some(tweet-b1))
    tweet-c1 = tweet("c1", "A A", none)
    search-tweet-t = tweet("search", "I J K L M N", none)

    sol = search(
      search-tweet-t,
      [list:
        tweet-a1, tweet-a2, tweet-a3,
        tweet-b1, tweet-b2, tweet-c1],
      2 / 6)

    sol is empty
  end

  # "Threshold should be inclusive"
  block:
    # 2 / 3 = 0.666 = 4 / 6
    tweet-a1 = tweet("a1", "A B C D", none)
    # 5 / 12 = 0.416 = ((2 / 6) * (3 / 4)) + ((4 / 6) * (1 / 4))
    tweet-a2 = tweet("a2", "B C D E", some(tweet-a1))
    # 23 / 48 = 0.479 = ((4 / 8) * (3 / 4)) + ((5 / 12) * (1 / 4))
    tweet-a3 = tweet("a3", "B B C C", some(tweet-a2))
    # 71 / 192 = 0.369 = ((2 / 6) * (3 / 4)) + ((23 / 48) * (1 / 4))
    tweet-a4 = tweet("a4", "C C D", some(tweet-a3))
    # 0 / 1 = 0.000 = 0 / 6
    tweet-b1 = tweet("b1", "D E F G H", none)
    # 1 / 2 = 0.500 = ((4 / 6) * (3 / 4)) + ((0 / 6) * (1 / 4))
    tweet-b2 = tweet("b2", "A A", some(tweet-b1))
    # 1 / 3 = 0.333 = 2 / 6
    tweet-c1 = tweet("c1", "B C D E", none)
    search-tweet-t = tweet("search", "A A B C", none)

    sol = search(
      search-tweet-t,
      [list: tweet-a4, tweet-b2, tweet-c1],
      5 / 12)

    sol is [list: tweet-a1, tweet-b2, tweet-a3, tweet-a2]
  end

  # "DocDiff is case insensitive"
  block:
    # 2 / 3 = 0.666 = 4 / 6
    tweet-a1 = tweet("a1", "a B C D", none)
    # 5 / 12 = 0.416 = ((2 / 6) * (3 / 4)) + ((4 / 6) * (1 / 4))
    tweet-a2 = tweet("a2", "B c D E", some(tweet-a1))
    # 23 / 48 = 0.479 = ((4 / 8) * (3 / 4)) + ((5 / 12) * (1 / 4))
    tweet-a3 = tweet("a3", "B b c C", some(tweet-a2))
    # 71 / 192 = 0.369 = ((2 / 6) * (3 / 4)) + ((23 / 48) * (1 / 4))
    tweet-a4 = tweet("a4", "c C D", some(tweet-a3))
    # 0 / 1 = 0.000 = 0 / 6
    tweet-b1 = tweet("b1", "D E F G H", none)
    # 1 / 2 = 0.500 = ((4 / 6) * (3 / 4)) + ((0 / 6) * (1 / 4))
    tweet-b2 = tweet("b2", "A A", some(tweet-b1))
    # 1 / 3 = 0.333 = 2 / 6
    tweet-c1 = tweet("c1", "B c D E", none)
    search-tweet-t = tweet("search", "A a B C", none)

    sol = search(
      search-tweet-t,
      [list: tweet-a4, tweet-b2, tweet-c1],
      1 / 6)

    sol is [list: tweet-a1, tweet-b2, tweet-a3, tweet-a2, tweet-a4, tweet-c1]
  end

  # "Properly handles multi-character and no-character words"
  block:
    # 2 / 3 = 0.666 = 4 / 6
    tweet-a1 = tweet("a1", "4lph4 B3t4  D3lt4", none)
    # 5 / 12 = 0.416 = ((2 / 6) * (3 / 4)) + ((4 / 6) * (1 / 4))
    tweet-a2 = tweet("a2", "B3t4  D3lt4 3ps1l0n", some(tweet-a1))
    # 23 / 48 = 0.479 = ((4 / 8) * (3 / 4)) + ((5 / 12) * (1 / 4))
    tweet-a3 = tweet("a3", "B3t4 B3t4  ", some(tweet-a2))
    # 71 / 192 = 0.369 = ((2 / 6) * (3 / 4)) + ((23 / 48) * (1 / 4))
    tweet-a4 = tweet("a4", "  D3lt4", some(tweet-a3))
    # 0 / 1 = 0.000 = 0 / 6
    tweet-b1 = tweet("b1", "D3lt4 3ps1l0n Z3t4 3t4 Th3t4", none)
    # 1 / 2 = 0.500 = ((4 / 6) * (3 / 4)) + ((0 / 6) * (1 / 4))
    tweet-b2 = tweet("b2", "4lph4 4lph4", some(tweet-b1))
    # 1 / 3 = 0.333 = 2 / 6
    tweet-c1 = tweet("c1", "B3t4  D3lt4 3ps1l0n", none)
    search-tweet-t = tweet("search", "4lph4 4lph4 B3t4 ", none)

    sol = search(
      search-tweet-t,
      [list: tweet-a4, tweet-b2, tweet-c1],
      1 / 6)

    sol is [list: tweet-a1, tweet-b2, tweet-a3, tweet-a2, tweet-a4, tweet-c1]
  end

  # "Does not remove numbers"
  block:
    # 2 / 3 = 0.666 = 4 / 6
    tweet-a1 = tweet("a1", "A1 A2 A3 A4", none)
    # 5 / 12 = 0.416 = ((2 / 6) * (3 / 4)) + ((4 / 6) * (1 / 4))
    tweet-a2 = tweet("a2", "A2 A3 A4 A5", some(tweet-a1))
    # 23 / 48 = 0.479 = ((4 / 8) * (3 / 4)) + ((5 / 12) * (1 / 4))
    tweet-a3 = tweet("a3", "A2 A2 A3 A3", some(tweet-a2))
    # 71 / 192 = 0.369 = ((2 / 6) * (3 / 4)) + ((23 / 48) * (1 / 4))
    tweet-a4 = tweet("a4", "A3 A3 A4", some(tweet-a3))
    # 0 / 1 = 0.000 = 0 / 6
    tweet-b1 = tweet("b1", "A4 A5 A6 A7 A8", none)
    # 1 / 2 = 0.500 = ((4 / 6) * (3 / 4)) + ((0 / 6) * (1 / 4))
    tweet-b2 = tweet("b2", "A1 A1", some(tweet-b1))
    # 1 / 3 = 0.333 = 2 / 6
    tweet-c1 = tweet("c1", "A2 A3 A4 A5", none)
    search-tweet-t = tweet("search", "A1 A1 A2 A3", none)

    sol = search(
      search-tweet-t,
      [list: tweet-a4, tweet-b2, tweet-c1],
      1 / 6)

    sol is [list: tweet-a1, tweet-b2, tweet-a3, tweet-a2, tweet-a4, tweet-c1]
  end
end
