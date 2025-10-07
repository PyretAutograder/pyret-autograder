fun num-rooms(building :: Building) -> Number:
  cases(Building) building:
    | ground => 0
    | story(_, rooms, _, below) => rooms + num-rooms(below)
  end
end
