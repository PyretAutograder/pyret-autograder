fun max-rooms(building :: Building) -> Number:
  shadow min = lam(a :: Number, b :: Number):
    if a < b: a else: b end
  end
  cases(Building) building:
    | ground => 0
    | story(_, rooms, _, below) => min(rooms, max-rooms(below))
  end
end
