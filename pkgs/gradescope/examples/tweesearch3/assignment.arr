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

fun find-size(current-tweet :: Tweet) -> Number:
  doc: ```Finds the size of a tweet tree.```
  current-tweet.children.foldl({(t, acc): find-size(t) + acc}, 1)
  where:
    1 is 1 # bogus test. This is not exported. However, a whaff can replace it.
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
  where:
  # "Basic test for functionality"
  block:
    # 31 / 70 = 0.442 = (0.60 * (3 / 6)) + (0.20 * (9 / 14)) + (0.20 * (1 / 14))
    tweet-a3 = tweet("a3", "A B", empty)
    # 1377 / 3500 = 0.393 = (0.60 * (3 / 6)) + (0.20 * (277 / 700)) + (0.20 * (1 / 14))
    tweet-a221 = tweet("a221", "B B C", empty)
    # 277 / 700 = 0.395 = (0.60 * (3 / 6)) + (0.20 * (47 / 140)) + (0.20 * (2 / 14))
    tweet-a22 = tweet("a22", "B B C D", [list: tweet-a221])
    # 267 / 700 = 0.381 = (0.60 * (8 / 16)) + (0.20 * (47 / 140)) + (0.20 * (1 / 14))
    tweet-a21 = tweet("a21", "A A A A", empty)
    # 47 / 140 = 0.335 = (0.60 * (2 / 8)) + (0.20 * (9 / 14)) + (0.20 * (4 / 14))
    tweet-a2 = tweet("a2", "C C D D", [list: tweet-a21, tweet-a22])
    # 24 / 35 = 0.685 = (0.60 * (6 / 6)) + (0.20 * (5 / 14)) + (0.20 * (1 / 14))
    tweet-a11 = tweet("a11", "A A B C", empty)
    # 5 / 14 = 0.357 = (0.60 * (2 / 6)) + (0.20 * (9 / 14)) + (0.20 * (2 / 14))
    tweet-a1 = tweet("a1", "B C D", [list: tweet-a11])
    # 9 / 14 = 0.642 = (0.75 * (4 / 6)) + (0.25 * (8 / 14))
    tweet-a = tweet("a", "A B C D", [list: tweet-a1, tweet-a2, tweet-a3])

    # 271 / 1000 = 0.271 = (0.60 * (2 / 6)) + (0.20 * (397 / 1400)) + (0.20 * (1 / 14))
    tweet-b121 = tweet("b121", "A", empty)
    # 397 / 1400 = 0.283 = (0.60 * (4 / 16)) + (0.20 * (21 / 40)) + (0.20 * (2 / 14))
    tweet-b12 = tweet("b12", "B B B B", [list: tweet-b121])
    # 337 / 1400 = 0.319 = (0.60 * (2 / 6)) + (0.20 * (21 / 40)) + (0.20 * (1 / 14))
    tweet-b11 = tweet("b11", "B C D", empty)
    # 21 / 40 = 0.525 = (0.60 * (6 / 8)) + (0.20 * (5 / 56)) + (0.20 * (4 / 14))
    tweet-b1 = tweet("b1", "A A B B", [list: tweet-b11, tweet-b12])
    # 5 / 56 = 0.089 = (0.75 * (0 / 6)) + (0.25 * (5 / 14))
    tweet-b = tweet("b", "D", [list: tweet-b1])

    # 43 / 56 = 0.767 = (0.75 * (6 / 6)) + (0.25 * (1 / 14))
    tweet-c = tweet("c", "A A B C", empty)

    search-tweet-t = tweet("search", "A A B C", empty)

    sol = search(
      search-tweet-t,
      [list: tweet-a, tweet-b, tweet-c],
      0.28)

    sol is [list: tweet-c, tweet-a11, tweet-a, tweet-b1, tweet-a3,
      tweet-a22, tweet-a221, tweet-a21, tweet-a1, tweet-a2,
      tweet-b11, tweet-b12]
  end

  # "No replies for any tweets"
  block:
    tweet-a = tweet("a", "A B C D", empty)
    tweet-b = tweet("b", "B C D E", empty)
    tweet-c = tweet("c", "C D E F", empty)
    tweet-d = tweet("d", "A A B C", empty)

    search-tweet-t = tweet("search", "A A B C", empty)

    sol = search(
      search-tweet-t,
      [list: tweet-a, tweet-b, tweet-c, tweet-d],
      2 / 6)

    sol is [list: tweet-d, tweet-a]
  end

  # "Just a reply thread"
  block:
    # 71 / 100 = 0.710 = ((6 / 6) * 0.60) + ((3 / 10) * 0.20) + ((1 / 4) * 0.20)
    tweet-a111 = tweet("a111", "A A B C", empty)
    # 3 / 10 = 0.300 = ((1 / 6) * 0.60) + ((1 / 2) * 0.20) + ((2 / 4) * 0.20)
    tweet-a11 = tweet("a11", "C D E F", [list: tweet-a111])
    # 1 / 2 = 0.500 = ((2 / 6) * 0.60) + ((3 / 4) * 0.20) + ((3 / 4) * 0.20)
    tweet-a1 = tweet("a1", "B C D E", [list: tweet-a11])
    # 3 / 4 = 0.750 = ((4 / 6) * 0.75) + ((4 / 4) * 0.25)
    tweet-a = tweet("a", "A B C D", [list: tweet-a1])

    search-tweet-t = tweet("search", "A A B C", empty)

    sol = search(
      search-tweet-t,
      [list: tweet-a],
      4 / 10)

    sol is [list: tweet-a, tweet-a111, tweet-a1]
  end

  # "Only 1 tweet"
  block:
    tweet-a = tweet("a", "A A B B", empty)
    search-tweet-t = tweet("search", "A A B C", empty)

    sol = search(
      search-tweet-t,
      [list: tweet-a],
      1 / 2)

    sol is [list: tweet-a]
  end

  # "Correctly calculates subtree size."
  block:
    # 1 / 24 = 0.015 = (1 / 6) * 0.25
    tweet-a = tweet("a", "A", empty)

    # 37 / 600 = 0.0617 = ((1 / 6) * 0.2) + ((17 / 120) * 0.2)
    tweet-b11 = tweet("b11", "A", empty)
    # 37 / 600 = 0.0617 = ((1 / 6) * 0.2) + ((17 / 120) * 0.2)
    tweet-b12 = tweet("b12", "A", empty)
    # 17 / 120 = 0.142 = ((3 / 6) * 0.2) + ((5 / 24) * 0.2)
    tweet-b1 = tweet("b1", "A", [list: tweet-b11, tweet-b12])
    # 3 / 40 = 0.075 = ((1 / 6) * 0.2) + ((5 / 24) * 0.2)
    tweet-b2 = tweet("b2", "A", empty)
    # 5 / 24 = 0.208 = (5 / 6) * 0.25
    tweet-b = tweet("b", "A", [list: tweet-b1, tweet-b2])

    search-tweet-t = tweet("search", "B", empty)

    sol = search(
      search-tweet-t,
      [list: tweet-a, tweet-b],
      5 / 24)

    sol is [list: tweet-b]

    sol-plus-epsilon = search(
      search-tweet-t,
      [list: tweet-a, tweet-b],
      (5 / 24) + 1e-10)

    sol-plus-epsilon is empty

    sol-minus-epsilon = search(
      search-tweet-t,
      [list: tweet-a, tweet-b],
      (5 / 24) - 1e-10)

    sol-minus-epsilon is [list: tweet-b]
  end

  # "Empty list of tweets should return empty"
  search(tweet("empty", "content", empty), empty, 0) is empty

  # "Threshold of 1 should only include exact match on content on sole
  #   original tweet (very strict)"
  block:
    tweet-a3 = tweet("a3", "A B", empty)
    tweet-a221 = tweet("a221", "A B C D", empty) # Exact, but parents not exact
    tweet-a22 = tweet("a22", "B B C D", [list: tweet-a221])
    tweet-a21 = tweet("a21", "A A A A", empty)
    tweet-a2 = tweet("a2", "C C D D", [list: tweet-a21, tweet-a22])
    tweet-a11 = tweet("a11", "A B C D", empty) # Exact, but not top level
    tweet-a1 = tweet("a1", "A B C D", [list: tweet-a11]) # Exact, but not top level
    tweet-a = tweet("a", "A B C D", [list: tweet-a1, tweet-a2, tweet-a3]) # Exact

    tweet-b = tweet("b", "A B C D", empty)

    search-tweet-t = tweet("search", "A B C D", empty)

    sol = search(search-tweet-t, [list: tweet-a], 1)

    sol is [list: tweet-a]

    sol2 = search(search-tweet-t, [list: tweet-a, tweet-b], 1)

    sol2 is empty
  end

  # "Threshold of 0 should include everything"
  block:
    # 31 / 70 = 0.442 = (0.60 * (3 / 6)) + (0.20 * (9 / 14)) + (0.20 * (1 / 14))
    tweet-a3 = tweet("a3", "A B", empty)
    # 1377 / 3500 = 0.393 = (0.60 * (3 / 6)) + (0.20 * (277 / 700)) + (0.20 * (1 / 14))
    tweet-a221 = tweet("a221", "B B C", empty)
    # 277 / 700 = 0.395 = (0.60 * (3 / 6)) + (0.20 * (47 / 140)) + (0.20 * (2 / 14))
    tweet-a22 = tweet("a22", "B B C D", [list: tweet-a221])
    # 267 / 700 = 0.381 = (0.60 * (8 / 16)) + (0.20 * (47 / 140)) + (0.20 * (1 / 14))
    tweet-a21 = tweet("a21", "A A A A", empty)
    # 47 / 140 = 0.335 = (0.60 * (2 / 8)) + (0.20 * (9 / 14)) + (0.20 * (4 / 14))
    tweet-a2 = tweet("a2", "C C D D", [list: tweet-a21, tweet-a22])
    # 24 / 35 = 0.685 = (0.60 * (6 / 6)) + (0.20 * (5 / 14)) + (0.20 * (1 / 14))
    tweet-a11 = tweet("a11", "A A B C", empty)
    # 5 / 14 = 0.357 = (0.60 * (2 / 6)) + (0.20 * (9 / 14)) + (0.20 * (2 / 14))
    tweet-a1 = tweet("a1", "B C D", [list: tweet-a11])
    # 9 / 14 = 0.642 = (0.75 * (4 / 6)) + (0.25 * (8 / 14))
    tweet-a = tweet("a", "A B C D", [list: tweet-a1, tweet-a2, tweet-a3])

    # 271 / 1000 = 0.271 = (0.60 * (2 / 6)) + (0.20 * (397 / 1400)) + (0.20 * (1 / 14))
    tweet-b121 = tweet("b121", "A", empty)
    # 397 / 1400 = 0.283 = (0.60 * (4 / 16)) + (0.20 * (21 / 40)) + (0.20 * (2 / 14))
    tweet-b12 = tweet("b12", "B B B B", [list: tweet-b121])
    # 337 / 1400 = 0.319 = (0.60 * (2 / 6)) + (0.20 * (21 / 40)) + (0.20 * (1 / 14))
    tweet-b11 = tweet("b11", "B C D", empty)
    # 21 / 40 = 0.525 = (0.60 * (6 / 8)) + (0.20 * (5 / 56)) + (0.20 * (4 / 14))
    tweet-b1 = tweet("b1", "A A B B", [list: tweet-b11, tweet-b12])
    # 5 / 56 = 0.089 = (0.75 * (0 / 6)) + (0.25 * (5 / 14))
    tweet-b = tweet("b", "D", [list: tweet-b1])

    # 43 / 56 = 0.767 = (0.75 * (6 / 6)) + (0.25 * (1 / 14))
    tweet-c = tweet("c", "A A B C", empty)

    search-tweet-t = tweet("search", "A A B C", empty)

    sol = search(
      search-tweet-t,
      [list: tweet-a, tweet-b, tweet-c],
      0)

    sol is [list: tweet-c, tweet-a11, tweet-a, tweet-b1, tweet-a3,
      tweet-a22, tweet-a221, tweet-a21, tweet-a1, tweet-a2,
      tweet-b11, tweet-b12, tweet-b121, tweet-b]
  end

  # "Ties present"
  block:
    # 5 / 14 = 0.357 = (0.60 * (5 / 14)) + (0.20 * (9 / 14)) + (0.20 * (1 / 14))
    tweet-a3 = tweet("a3", "A A B D D D", empty)
    # 1377 / 3500 = 0.393 = (0.60 * (3 / 6)) + (0.20 * (277 / 700)) + (0.20 * (1 / 14))
    tweet-a221 = tweet("a221", "B B C", empty)
    # 277 / 700 = 0.395 = (0.60 * (3 / 6)) + (0.20 * (47 / 140)) + (0.20 * (2 / 14))
    tweet-a22 = tweet("a22", "B B C D", [list: tweet-a221])
    # 267 / 700 = 0.381 = (0.60 * (8 / 16)) + (0.20 * (47 / 140)) + (0.20 * (1 / 14))
    tweet-a21 = tweet("a21", "A A A A", empty)
    # 47 / 140 = 0.335 = (0.60 * (2 / 8)) + (0.20 * (9 / 14)) + (0.20 * (4 / 14))
    tweet-a2 = tweet("a2", "C C D D", [list: tweet-a21, tweet-a22])
    # 24 / 35 = 0.685 = (0.60 * (6 / 6)) + (0.20 * (5 / 14)) + (0.20 * (1 / 14))
    tweet-a11 = tweet("a11", "A A B C", empty)
    # 5 / 14 = 0.357 = (0.60 * (2 / 6)) + (0.20 * (9 / 14)) + (0.20 * (2 / 14))
    tweet-a1 = tweet("a1", "B C D", [list: tweet-a11])
    # 9 / 14 = 0.642 = (0.75 * (4 / 6)) + (0.25 * (8 / 14))
    tweet-a = tweet("a", "A B C D", [list: tweet-a1, tweet-a2, tweet-a3])

    # 271 / 1000 = 0.271 = (0.60 * (2 / 6)) + (0.20 * (397 / 1400)) + (0.20 * (1 / 14))
    tweet-b121 = tweet("b121", "A", empty)
    # 397 / 1400 = 0.283 = (0.60 * (4 / 16)) + (0.20 * (21 / 40)) + (0.20 * (2 / 14))
    tweet-b12 = tweet("b12", "B B B B", [list: tweet-b121])
    # 337 / 1400 = 0.319 = (0.60 * (2 / 6)) + (0.20 * (21 / 40)) + (0.20 * (1 / 14))
    tweet-b11 = tweet("b11", "B C D", empty)
    # 21 / 40 = 0.525 = (0.60 * (6 / 8)) + (0.20 * (5 / 56)) + (0.20 * (4 / 14))
    tweet-b1 = tweet("b1", "A A B B", [list: tweet-b11, tweet-b12])
    # 5 / 56 = 0.089 = (0.75 * (0 / 6)) + (0.25 * (5 / 14))
    tweet-b = tweet("b", "D", [list: tweet-b1])

    # 9 / 14 = 0.642 = (0.75 * (5 / 6)) + (0.25 * (1 / 14))
    tweet-c = tweet("c", "A A B D", empty)

    search-tweet-t = tweet("search", "A A B C", empty)

    sol = search(
      search-tweet-t,
      [list: tweet-a, tweet-b, tweet-c],
      0.28)

    sol satisfies oracle([list:
        [list: tweet-a11],
        [list: tweet-a, tweet-c],
        [list: tweet-b1],
        [list: tweet-a22],
        [list: tweet-a221],
        [list: tweet-a21],
        [list: tweet-a1, tweet-a3],
        [list: tweet-a2],
        [list: tweet-b11],
        [list: tweet-b12]],
      _)
  end

  # "All tweets 0 compare value (but not 0 relevance!)"
  block:
    tweet-a3 = tweet("a3", "A B", empty)
    tweet-a221 = tweet("a221", "B B C", empty)
    tweet-a22 = tweet("a22", "B B C D", [list: tweet-a221])
    tweet-a21 = tweet("a21", "A A A A", empty)
    tweet-a2 = tweet("a2", "C C D D", [list: tweet-a21, tweet-a22])
    tweet-a11 = tweet("a11", "A A B C", empty)
    tweet-a1 = tweet("a1", "B C D", [list: tweet-a11])
    tweet-a = tweet("a", "A B C D", [list: tweet-a1, tweet-a2, tweet-a3])

    tweet-b121 = tweet("b121", "A", empty)
    tweet-b12 = tweet("b12", "B B B B", [list: tweet-b121])
    tweet-b11 = tweet("b11", "B C D", empty)
    tweet-b1 = tweet("b1", "A A B B", [list: tweet-b11, tweet-b12])
    tweet-b = tweet("b", "D", [list: tweet-b1])

    tweet-c = tweet("c", "A A B C", empty)

    search-tweet-t = tweet("search", "NOPE", empty)

    sol = search(
      search-tweet-t,
      [list: tweet-a, tweet-b, tweet-c],
      1 / 8)

    sol is [list: tweet-a]
  end

  # "Threshold should be inclusive"
  block:
    # 31 / 70 = 0.442 = (0.60 * (3 / 6)) + (0.20 * (9 / 14)) + (0.20 * (1 / 14))
    tweet-a3 = tweet("a3", "A B", empty)
    # 1377 / 3500 = 0.393 = (0.60 * (3 / 6)) + (0.20 * (277 / 700)) + (0.20 * (1 / 14))
    tweet-a221 = tweet("a221", "B B C", empty)
    # 277 / 700 = 0.395 = (0.60 * (3 / 6)) + (0.20 * (47 / 140)) + (0.20 * (2 / 14))
    tweet-a22 = tweet("a22", "B B C D", [list: tweet-a221])
    # 267 / 700 = 0.381 = (0.60 * (8 / 16)) + (0.20 * (47 / 140)) + (0.20 * (1 / 14))
    tweet-a21 = tweet("a21", "A A A A", empty)
    # 47 / 140 = 0.335 = (0.60 * (2 / 8)) + (0.20 * (9 / 14)) + (0.20 * (4 / 14))
    tweet-a2 = tweet("a2", "C C D D", [list: tweet-a21, tweet-a22])
    # 24 / 35 = 0.685 = (0.60 * (6 / 6)) + (0.20 * (5 / 14)) + (0.20 * (1 / 14))
    tweet-a11 = tweet("a11", "A A B C", empty)
    # 5 / 14 = 0.357 = (0.60 * (2 / 6)) + (0.20 * (9 / 14)) + (0.20 * (2 / 14))
    tweet-a1 = tweet("a1", "B C D", [list: tweet-a11])
    # 9 / 14 = 0.642 = (0.75 * (4 / 6)) + (0.25 * (8 / 14))
    tweet-a = tweet("a", "A B C D", [list: tweet-a1, tweet-a2, tweet-a3])

    # 271 / 1000 = 0.271 = (0.60 * (2 / 6)) + (0.20 * (397 / 1400)) + (0.20 * (1 / 14))
    tweet-b121 = tweet("b121", "A", empty)
    # 397 / 1400 = 0.283 = (0.60 * (4 / 16)) + (0.20 * (21 / 40)) + (0.20 * (2 / 14))
    tweet-b12 = tweet("b12", "B B B B", [list: tweet-b121])
    # 337 / 1400 = 0.319 = (0.60 * (2 / 6)) + (0.20 * (21 / 40)) + (0.20 * (1 / 14))
    tweet-b11 = tweet("b11", "B C D", empty)
    # 21 / 40 = 0.525 = (0.60 * (6 / 8)) + (0.20 * (5 / 56)) + (0.20 * (4 / 14))
    tweet-b1 = tweet("b1", "A A B B", [list: tweet-b11, tweet-b12])
    # 5 / 56 = 0.089 = (0.75 * (0 / 6)) + (0.25 * (5 / 14))
    tweet-b = tweet("b", "D", [list: tweet-b1])

    # 43 / 56 = 0.767 = (0.75 * (6 / 6)) + (0.25 * (1 / 14))
    tweet-c = tweet("c", "A A B C", empty)

    search-tweet-t = tweet("search", "A A B C", empty)

    sol = search(
      search-tweet-t,
      [list: tweet-a, tweet-b, tweet-c],
      397 / 1400)

    sol is [list: tweet-c, tweet-a11, tweet-a, tweet-b1, tweet-a3,
      tweet-a22, tweet-a221, tweet-a21, tweet-a1, tweet-a2,
      tweet-b11, tweet-b12]
  end

  # "DocDiff is case insensitive"
  block:
    tweet-a3 = tweet("a3", "a B", empty)
    tweet-a221 = tweet("a221", "B b C", empty)
    tweet-a22 = tweet("a22", "b B C d", [list: tweet-a221])
    tweet-a21 = tweet("a21", "A a A a", empty)
    tweet-a2 = tweet("a2", "C C d D", [list: tweet-a21, tweet-a22])
    tweet-a11 = tweet("a11", "a A B C", empty)
    tweet-a1 = tweet("a1", "B c D", [list: tweet-a11])
    tweet-a = tweet("a", "A b c D", [list: tweet-a1, tweet-a2, tweet-a3])

    tweet-b121 = tweet("b121", "A", empty)
    tweet-b12 = tweet("b12", "b b B B", [list: tweet-b121])
    tweet-b11 = tweet("b11", "B c D", empty)
    tweet-b1 = tweet("b1", "A a b B", [list: tweet-b11, tweet-b12])
    tweet-b = tweet("b", "D", [list: tweet-b1])

    tweet-c = tweet("c", "a a B C", empty)

    search-tweet-t = tweet("search", "A a B c", empty)

    sol = search(
      search-tweet-t,
      [list: tweet-a, tweet-b, tweet-c],
      0.28)

    sol is [list: tweet-c, tweet-a11, tweet-a, tweet-b1, tweet-a3,
      tweet-a22, tweet-a221, tweet-a21, tweet-a1, tweet-a2,
      tweet-b11, tweet-b12]
  end

  # "Properly handles multi-character and no-character words"
  block:
    fun funify(str :: String) -> String:
      doc: ```Converts strings to fun words.```
      string-split-all(str, " ").map({(char):
          ask:
            | char == "A" then: "4lph4"
            | char == "B" then: "B3t4"
            | char == "C" then: ""
            | char == "D" then: "D3lt4"
            | otherwise: raise("Missed a word.")
          end})
        .join-str(" ")
    end

    tweet-a3 = tweet("a3", funify("A B"), empty)
    tweet-a221 = tweet("a221", funify("B B C"), empty)
    tweet-a22 = tweet("a22", funify("B B C D"), [list: tweet-a221])
    tweet-a21 = tweet("a21", funify("A A A A"), empty)
    tweet-a2 = tweet("a2", funify("C C D D"), [list: tweet-a21, tweet-a22])
    tweet-a11 = tweet("a11", funify("A A B C"), empty)
    tweet-a1 = tweet("a1", funify("B C D"), [list: tweet-a11])
    tweet-a = tweet("a", funify("A B C D"), [list: tweet-a1, tweet-a2, tweet-a3])

    tweet-b121 = tweet("b121", funify("A"), empty)
    tweet-b12 = tweet("b12", funify("B B B B"), [list: tweet-b121])
    tweet-b11 = tweet("b11", funify("B C D"), empty)
    tweet-b1 = tweet("b1", funify("A A B B"), [list: tweet-b11, tweet-b12])
    tweet-b = tweet("b", funify("D"), [list: tweet-b1])

    tweet-c = tweet("c", funify("A A B C"), empty)

    search-tweet-t = tweet("search", funify("A A B C"), empty)

    sol = search(
      search-tweet-t,
      [list: tweet-a, tweet-b, tweet-c],
      0.28)

    sol is [list: tweet-c, tweet-a11, tweet-a, tweet-b1, tweet-a3,
      tweet-a22, tweet-a221, tweet-a21, tweet-a1, tweet-a2,
      tweet-b11, tweet-b12]
  end

  # "Does not remove numbers"
  block:
    fun numify(str :: String) -> String:
      doc: ```Converts strings to numbered words.```
      string-split-all(str, " ").map({(char):
          ask:
            | char == "A" then: "A1"
            | char == "B" then: "A2"
            | char == "C" then: "A3"
            | char == "D" then: "A4"
            | otherwise: raise("Missed a word.")
          end})
        .join-str(" ")
    end

    tweet-a3 = tweet("a3", numify("A B"), empty)
    tweet-a221 = tweet("a221", numify("B B C"), empty)
    tweet-a22 = tweet("a22", numify("B B C D"), [list: tweet-a221])
    tweet-a21 = tweet("a21", numify("A A A A"), empty)
    tweet-a2 = tweet("a2", numify("C C D D"), [list: tweet-a21, tweet-a22])
    tweet-a11 = tweet("a11", numify("A A B C"), empty)
    tweet-a1 = tweet("a1", numify("B C D"), [list: tweet-a11])
    tweet-a = tweet("a", numify("A B C D"), [list: tweet-a1, tweet-a2, tweet-a3])

    tweet-b121 = tweet("b121", numify("A"), empty)
    tweet-b12 = tweet("b12", numify("B B B B"), [list: tweet-b121])
    tweet-b11 = tweet("b11", numify("B C D"), empty)
    tweet-b1 = tweet("b1", numify("A A B B"), [list: tweet-b11, tweet-b12])
    tweet-b = tweet("b", numify("D"), [list: tweet-b1])

    tweet-c = tweet("c", numify("A A B C"), empty)

    search-tweet-t = tweet("search", numify("A A B C"), empty)

    sol = search(
      search-tweet-t,
      [list: tweet-a, tweet-b, tweet-c],
      0.28)

    sol is [list: tweet-c, tweet-a11, tweet-a, tweet-b1, tweet-a3,
      tweet-a22, tweet-a221, tweet-a21, tweet-a1, tweet-a2,
      tweet-b11, tweet-b12]
  end
end
