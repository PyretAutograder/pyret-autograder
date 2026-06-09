fun num-rooms(building :: Building) -> Number:
  cases(Building) building:
    | ground => 0
    | story(_, above-rooms, _, below) =>
      cases(Building) below:
      | ground => above-rooms
      | story(_, below-rooms, _, shadow below) =>
        below-rooms + num-rooms(below)
      end
  end
end
