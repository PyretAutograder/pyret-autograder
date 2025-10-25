fun max-rooms(building :: Building) -> Number:
  cases(Building) building:
    | ground => 0
    | story(_, rooms, _, below) => rooms + max-rooms(below)
  end
end
