provide: data Building end
provide-types *

# The given data definition.
data Building:
  | ground
  | story(
      height :: NumNonNegative,
      rooms :: NumNonNegative,
      color :: String,
      below :: Building)
end
