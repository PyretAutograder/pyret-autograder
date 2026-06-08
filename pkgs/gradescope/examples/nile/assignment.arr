provide: recommend, popular-pairs end
# END HEADER

include file("submission/assignment-support.arr")
import append, distinct, foldl from lists

# ---- reference implementation ----
#| wheat (tdelvecc, Aug 26, 2020): 
    Basic wheat; follows specs without additional features.
|#


fun get-all-books(records :: List<File>) -> List<String>:
  doc: ```Gets all of the books out of a list of records.```
  records
    .map(_.content)
    .foldl(append, empty)
end

fun gather-recos<A>(recos :: List<Recommendation<A>>) -> Recommendation<A>:
  doc: ```Takes a list of recommendation and combines the largest ones
       into a single recommendation.```
  for foldl(
      best-reco :: Recommendation<A> from recommendation(0, empty),
      book-reco :: Recommendation<A> from recos):
    ask:
        # If one reco is better than the other, then take that one.
      | book-reco.count > best-reco.count then: book-reco
      | book-reco.count < best-reco.count then: best-reco
        # If both recos have 0 count, then keep book list empty
      | (book-reco.count == 0) and (best-reco.count == 0) then: best-reco
      | book-reco.count == best-reco.count then: 
        # Take the total-reco and add the contents of book-reco, except duplicates.
        recommendation(best-reco.count, distinct(best-reco.content + book-reco.content))
    end
  end
end

fun recommend(title :: String, book-records :: List<File>) 
  -> Recommendation<String>:
  doc: ```Takes in the title of a book and a list of files,
       and returns a recommendation of book(s) to be paired with title
       based on the files in book-records.```
  book-records
    ^ get-all-books
    ^ filter(_ <> title, _) # Duplicates are ok since gather-recos will handle them
    ^ map({(book): # Create individual recommendations for each book
      recommendation(
        book-records
        # Find number of records with both book and title
          .filter({(record): record.content.member(book)})
          .filter({(record): record.content.member(title)})
          .length(),
        [list: book])}, _)
    ^ gather-recos
end

fun popular-pairs(book-records :: List<File>) -> Recommendation<BookPair>:
  doc: ```Takes in a list of files and returns a recommendation of
       the most popular pair(s) of books in records.```
  book-records
    ^ get-all-books
    ^ map({(book): # Create individual pair recommendations for each book
      reco = recommend(book, book-records)
      recommendation(reco.count, reco.content.map(pair(_, book)))}, _)
    ^ gather-recos
end

# ---- test fixtures and helpers ----
fun index-of(n :: String, ch :: String) -> Number:
  doc: "returns index of ch in n, returns length of n if ch not found"
  if string-equal(n, "") or string-equal(string-char-at(n,0), ch):
    0
  else:
    1 + index-of(string-substring(n, 1, string-length(n)), ch)
  end
end

fun same-rec(t1 :: Recommendation, t2 :: Recommendation) -> Boolean:
  t1 == t2
end

bl1 = file("1", [list: "aa", "bb", "cc", "dd", "ee", "ff", "gg"])
bl2 = file("2", [list: "aa", "bb"])
bl3 = file("3", [list: "aa", "bb", "cc", "dd"])
bl4 = file("4", [list: "ff", "dd", "ee"])
bl5 = file("5", [list: "bb", "aa"])

# recommend

# ---- tests ----
check "recommend":
  block:
    # normal-recommend:: Normal operational conditions for recommend":
    # recommend on a file with two elements when one 
    # is the input should return a recommendation for the other
    same-rec(recommend("aa",[list: bl2]),recommendation(1,[list: "bb"])) is true

    # recommend when there are multiple other books on the 
    # file should return a recommendation with those others
    same-rec(recommend("dd",[list: bl4]),recommendation(1,[list: "ff","ee"]))
      is true

    # recommend on two files when one element is in
    # both files should return that element
    same-rec(recommend("aa",[list: bl3,bl2]),recommendation(2,[list: "bb"]))
      is true

    # recommend on three files when one element is in
    # all three should return that element
    same-rec(recommend("aa",[list: bl5,bl2,bl2]),recommendation(3,[list: "bb"]))
      is true

    # recommend on multiple files when one file does not have the input 
    # should just return the closest recommendation from files with that input
    same-rec(recommend("aa",[list: bl2,bl4]),recommendation(1,[list: "bb"]))
      is true
  end
  block:
    # no-recommend-match:: Confirms recommend can handle a call where     the title is
    # recommend on a file where the inputted element does not exist 
    # should return an empty recommendation
    same-rec(recommend("cc",[list: bl2]),recommendation(0,empty)) is true
  end
  block:
    # empty:: Confirms functions handle empty inputs":
    # recommend with no files returns an empty recommendation
    same-rec(recommend("aa",empty),recommendation(0,empty)) is true

    # popular-pairs when no files are given return empty recommendations
    same-rec(popular-pairs(empty), recommendation(0, empty)) is true
  end
  block:
    # recommend and popular-pairs: case sensitivity checks":
    x = file("x", [list: "a", "b"])
    y = file("y", [list: "A", "b"])
  
    same-rec(recommend("b", [list: x, y]), recommendation(1, [list: "a", "A"])) 
      is true
    same-rec(popular-pairs([list: x, y]), 
      recommendation(1, [list: pair("a", "b"), pair("A", "b")])) is true
  end
end

check "popular-pairs":
  block:
    # normal-popular-pairs:: Normal operational conditions for popular-pairs":
    # popular-pairs when only one file is given
    same-rec(popular-pairs([list: bl4]), 
        recommendation(1, [list: pair("ff","dd"), pair("ee","ff"), pair("dd","ee")])) is true

    # simple popular-pairs with one pair represented on both files
    same-rec(popular-pairs([list: bl1,bl2]),
        recommendation(2,[list: pair("bb","aa")])) is true

    # popular-pairs between two files where three pairs are represented on both
    same-rec(popular-pairs([list: bl4,bl1]),
        recommendation(2,[list: pair("ff","dd"),pair("ee","ff"),pair("dd","ee")])) is true

    # popular-pairs with duplicates of one file that 
    # has one pair of books repreated four times
    same-rec(popular-pairs([list: bl2,bl2,bl1,bl2]),
        recommendation(4,[list: pair("aa","bb")])) is true

    # popular-pairs with five files should successfully generate the most 
    # popular pair (in this case repeated four times)
    same-rec(popular-pairs([list: bl1,bl2,bl3,bl4,bl5]),
        recommendation(4,[list: pair("bb","aa")])) is true
  end
  block:
    # no-pair-overlap:: Confirms popular-pairs can       handle files with no overlap`
    # popular-pairs when there is no overlap between book files
    same-rec(popular-pairs([list: bl2,bl4]),
        recommendation(1,[list: pair("bb","aa"), pair("ff","dd"), pair("dd","ee"), pair("ee","ff")])) 
      is true
  end
  block:
    # empty:: Confirms functions handle empty inputs":
    # recommend with no files returns an empty recommendation
    same-rec(recommend("aa",empty),recommendation(0,empty)) is true

    # popular-pairs when no files are given return empty recommendations
    same-rec(popular-pairs(empty), recommendation(0, empty)) is true
  end
  block:
    # recommend and popular-pairs: case sensitivity checks":
    x = file("x", [list: "a", "b"])
    y = file("y", [list: "A", "b"])
  
    same-rec(recommend("b", [list: x, y]), recommendation(1, [list: "a", "A"])) 
      is true
    same-rec(popular-pairs([list: x, y]), 
      recommendation(1, [list: pair("a", "b"), pair("A", "b")])) is true
  end
end
