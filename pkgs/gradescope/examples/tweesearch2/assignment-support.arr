# CSCI0190 (Fall 2021)

provide: data Tweet end

# Ensure that tweet content and author are not empty strings
fun is-non-empty(s :: String) -> Boolean:
  string-length(s) > 0
end

# A Tweet from part 2 has an author and content, as well as
# a parent tweet which it is "quoting".
data Tweet:
  | tweet(
      author :: String%(is-non-empty), 
      content :: String%(is-non-empty),
      parent :: Option<Tweet>)
end
