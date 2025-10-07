fun num-rooms(building :: Building) -> Number:
  cases(Building) building:
    | ground => 0
    | story(_, above-rooms, _, below) =>
      cases(Building) below:
      | ground => above-rooms
      | story(_, below-rooms, _ shadow below) =>
        num-rooms(below-rooms, below)
  end
end
