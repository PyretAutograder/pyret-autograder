fun num-rooms(building :: Building) -> Number:
  fun help(shadow building :: Building, acc :: Number) -> Number:
    cases(Building) building:
      | ground => acc
      | story(_, rooms, _, below) => help(below, acc + rooms)
    end
  end

  help(building, 0)
end
