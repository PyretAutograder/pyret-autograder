check "foldl-reference-tests":
  foldl([list: 1, 2, 3, 4], lam(acc, x): acc + x end, 0) is 10
  foldl([list: 1, 2, 3], lam(acc, x): acc - x end, 0) is -6
  foldl([list: "a", "b", "c"], lam(acc, x): acc + x end, "") is "abc"
  foldl([list:], lam(acc, x): acc + x end, 42) is 42
end

check "foldr-reference-tests":
  foldr([list: 1, 2, 3, 4], lam(acc, x): acc + x end, 0) is 10
  foldr([list: 1, 2, 3], lam(acc, x): acc - x end, 0) is 2
  foldr([list: "a", "b", "c"], lam(acc, x): acc + x end, "") is "cba"
  foldr([list:], lam(acc, x): acc + x end, 42) is 42
end
