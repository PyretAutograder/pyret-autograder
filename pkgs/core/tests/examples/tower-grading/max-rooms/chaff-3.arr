fun max-rooms(building :: Building) -> Number:
  shadow max = lam(a :: Number, b :: Number):
    if a > b: a else: b end
  end
  cases(Building) building:
    | ground => 0
    | story(height, _, _, below) => max(height, max-rooms(below))
  end
end
