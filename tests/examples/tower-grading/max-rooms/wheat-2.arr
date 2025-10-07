fun max-rooms(building :: Building) -> Number:
  shadow max = lam(a :: Number, b :: Number):
    if a > b: a else: b end
  end
  fun help(shadow building :: Building, acc :: Number):
    cases(Building) building:
      | ground => acc
      | story(_, rooms, _, below) => help(below, max(acc, rooms))
    end
  end
  help(building, 0)
end
