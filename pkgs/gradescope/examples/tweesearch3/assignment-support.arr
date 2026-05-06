provide: * end
provide: type * end

# A Tweet from part 3 has an author and content, as well as
# a list of children tweets which "quote" it.
data Tweet:
  | tweet(
      author :: String,
      content :: String,
      children :: List<Tweet>)
end

data Tv-pair<A, B>:
  | tv-pair(tag :: A, value :: B)
end

type Relevance = Number

# ==============================
# Oracle Utility
# ==============================

fun oracle(
    format :: List<List<String>>,
    possibility :: List<String>)
  -> Boolean:
  doc: ```Checks if possibility is a valid solution based on format.
       Each List in format is an equivalence class.```
  cases (List) format:
    | empty => is-empty(possibility)
    | link(format-f, format-r) =>
      cases (List) possibility:
        | empty => format.all(is-empty)
        | link(poss-f, poss-r) =>
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
end
