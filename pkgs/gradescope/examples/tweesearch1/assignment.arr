provide: search end
provide: search end

include file("submission/assignment-support.arr")

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
  where:
  # "Basic test for functionality"
  block:
    tweet-1 = tweet("1", "A B C D")   # 4 / 6
    tweet-2 = tweet("2", "B C D E")   # 2 / 6
    tweet-3 = tweet("3", "B B C C")   # 4 / 8
    tweet-4 = tweet("4", "C C D")     # 2 / 6
    tweet-5 = tweet("5", "D E F G H") # 0 / 6
    tweet-6 = tweet("6", "A A")       # 4 / 6
    search-tweet-t = tweet("search", "A A B C")

    sol = search(
      search-tweet-t,
      [list: tweet-1, tweet-2, tweet-3, tweet-4, tweet-5, tweet-6],
      1 / 6)

    sol satisfies oracle([list:
        [list: tweet-1, tweet-6],
        [list: tweet-3],
        [list: tweet-2, tweet-4]],
      _)
  end

  # "Empty list of tweets should return empty"
  search(tweet("", "content"), empty, 0) is empty

  # "Threshold of 1 should only include exact match on content"
  block:
    tweet-1 = tweet("1", "A")
    tweet-2 = tweet("2", "B")
    tweet-3 = tweet("3", "C")
    search-tweet-t = tweet("search", "A")

    sol = search(
      search-tweet-t,
      [list: tweet-1, tweet-2, tweet-3],
      1)

    sol is [list: tweet-1]
  end

  # "Threshold of 0 should include everything"
  block:
    tweet-1 = tweet("1", "A")
    tweet-2 = tweet("2", "B")
    tweet-3 = tweet("3", "C")
    search-tweet-t = tweet("search", "A")

    sol = search(
      search-tweet-t,
      [list: tweet-1, tweet-2, tweet-3],
      0)

    sol satisfies oracle([list:
        [list: tweet-1],
        [list: tweet-2, tweet-3]],
      _)
  end

  # "All tweets are tied"
  block:
    tweet-1 = tweet("1", "A B C D")
    tweet-2 = tweet("2", "B C D E")
    tweet-3 = tweet("3", "C D E F")
    tweet-4 = tweet("4", "D E F G")
    tweet-5 = tweet("5", "E F G H")
    tweet-6 = tweet("6", "F G H I")
    search-tweet-t = tweet("search", "D H")

    sol = search(
      search-tweet-t,
      [list: tweet-1, tweet-2, tweet-3, tweet-4, tweet-5, tweet-6],
      1 / 5)

    sol satisfies oracle([list:
        [list: tweet-1, tweet-2, tweet-3, tweet-4, tweet-5, tweet-6]],
      _)
  end

  # "All tweets 0 relevance"
  block:
    tweet-1 = tweet("1", "A B C D")
    tweet-2 = tweet("2", "B C D E")
    tweet-3 = tweet("3", "B B C C")
    tweet-4 = tweet("4", "C C D")
    tweet-5 = tweet("5", "D E F G H")
    tweet-6 = tweet("6", "A A")
    search-tweet-t = tweet("search", "I J K L M N")

    sol = search(
      search-tweet-t,
      [list: tweet-1, tweet-2, tweet-3, tweet-4, tweet-5, tweet-6],
      2 / 6)

    sol is empty
  end

  # "Threshold should be inclusive"
  block:
    tweet-1 = tweet("1", "A B C D")   # 4 / 6
    tweet-2 = tweet("2", "B C D E")   # 2 / 6
    tweet-3 = tweet("3", "B B C C")   # 4 / 8
    tweet-4 = tweet("4", "C C D")     # 2 / 6
    tweet-5 = tweet("5", "D E F G H") # 0 / 6
    tweet-6 = tweet("6", "A A")       # 4 / 6
    search-tweet-t = tweet("search", "A A B C")

    sol = search(
      search-tweet-t,
      [list: tweet-1, tweet-2, tweet-3, tweet-4, tweet-5, tweet-6],
      2 / 6)

    sol satisfies oracle([list:
        [list: tweet-1, tweet-6],
        [list: tweet-3],
        [list: tweet-2, tweet-4]],
      _)
  end

  # "Doesn't care about duplicates"
  block:
    tweet-1  = tweet("1",  "A B C D")   # 4 / 6
    tweet-1a = tweet("1a", "A B C D")   # 4 / 6
    tweet-1b = tweet("1b", "A B C D")   # 4 / 6
    tweet-2  = tweet("2",  "B C D E")   # 2 / 6
    tweet-2a = tweet("2a", "B C D E")   # 2 / 6
    tweet-2b = tweet("2b", "B C D E")   # 2 / 6
    tweet-3  = tweet("3",  "B B C C")   # 4 / 8
    tweet-4  = tweet("4",  "C C D")     # 2 / 6
    tweet-5  = tweet("5",  "D E F G H") # 0 / 6
    tweet-6  = tweet("6",  "A A")       # 4 / 6
    search-tweet-t = tweet("search", "A A B C")

    sol = search(
      search-tweet-t,
      [list: tweet-1, tweet-1a, tweet-1b, tweet-2, tweet-2a, tweet-2b,
        tweet-3, tweet-4, tweet-5, tweet-6],
      1 / 6)

    sol satisfies oracle([list:
        [list: tweet-1, tweet-1a, tweet-1b, tweet-6],
        [list: tweet-3],
        [list: tweet-2, tweet-2a, tweet-2b, tweet-4]],
      _)
  end

  # "DocDiff is case insensitive"
  block:
    tweet-1 = tweet("1", "A b C D")   # 4 / 6
    tweet-2 = tweet("2", "B C D E")   # 2 / 6
    tweet-3 = tweet("3", "B B C C")   # 4 / 8
    tweet-4 = tweet("4", "C c D")     # 2 / 6
    tweet-5 = tweet("5", "D E F G H") # 0 / 6
    tweet-6 = tweet("6", "A a")       # 4 / 6
    search-tweet-t = tweet("search", "a A B C")

    sol = search(
      search-tweet-t,
      [list: tweet-1, tweet-2, tweet-3, tweet-4, tweet-5, tweet-6],
      1 / 6)

    sol satisfies oracle([list:
        [list: tweet-1, tweet-6],
        [list: tweet-3],
        [list: tweet-2, tweet-4]],
      _)
  end

  # "Properly handles multi-character and no-character words"
  block:
    tweet-1 = tweet("1", "4lph4 B3t4  D3lt4")   # 4 / 6
    tweet-2 = tweet("2", "B3t4  D3lt4 3ps1l0n")  # 2 / 6
    tweet-3 = tweet("3", "B3t4 B3t4  ")           # 4 / 8
    tweet-4 = tweet("4", "  D3lt4")               # 2 / 6
    tweet-5 = tweet("5", "D3lt4 3ps1l0n z3t4 3t4 Th3t4") # 0 / 6
    tweet-6 = tweet("6", "4lph4 4lph4")           # 4 / 6
    search-tweet-t = tweet("search", "4lph4 4lph4 B3t4 ")

    sol = search(
      search-tweet-t,
      [list: tweet-1, tweet-2, tweet-3, tweet-4, tweet-5, tweet-6],
      1 / 6)

    sol satisfies oracle([list:
        [list: tweet-1, tweet-6],
        [list: tweet-3],
        [list: tweet-2, tweet-4]],
      _)
  end

  # "Does not remove numbers"
  block:
    tweet-1 = tweet("1", "A1 A2 A3 A4")    # 4 / 6
    tweet-2 = tweet("2", "A2 A3 A4 A5")    # 2 / 6
    tweet-3 = tweet("3", "A2 A2 A3 A3")    # 4 / 8
    tweet-4 = tweet("4", "A3 A3 A4")       # 2 / 6
    tweet-5 = tweet("5", "A4 A5 A6 A7 A8") # 0 / 6
    tweet-6 = tweet("6", "A1 A1")          # 4 / 6
    search-tweet-t = tweet("search", "A1 A1 A2 A3")

    sol = search(
      search-tweet-t,
      [list: tweet-1, tweet-2, tweet-3, tweet-4, tweet-5, tweet-6],
      1 / 6)

    sol satisfies oracle([list:
        [list: tweet-1, tweet-6],
        [list: tweet-3],
        [list: tweet-2, tweet-4]],
      _)
  end
end
