# CSCI0190 (Fall 2021)

provide: data Tweet end

# A Tweet from part 3 has an author and content, as well as
# a list of children tweets which "quote" it.
data Tweet:
  | tweet(
      author :: String, 
      content :: String,
      children :: List<Tweet>)
end
