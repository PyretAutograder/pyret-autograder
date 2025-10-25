fun num-rooms(building :: Building) -> Number:
  cases(Building) building:
    | ground => 0
    | story(height, _, _, below) => height + num-rooms(below)
  end
end
