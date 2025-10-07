fun max(a :: Number, b :: Number):
  if a > b:
    a
  else:
    b
  end
end

data Building:
  | ground
  | story(
      height :: NumNonNegative,
      rooms :: NumNonNegative,
      color :: String,
      below :: Building)
end

evg = ground
ev1 = story(2, 90, "blue", evg)
ev2 = story(3, 90, "red", ev1)
ev3 = story(1, 80, "purple", ev2)
ev4 = story(4, 100, "yellow", ev3)
ev5 = story(4, 0, "black", ev4)

ivg = ground
iv1 = story(10, 0, "pink", ivg)
iv2 = story(1, 10, "pink", iv1)

fun building-tmpl(building :: Building):
  cases(Building) building:
    | ground => ...
    | story(height, rooms, color, below) =>
      ... building-tmpl(below) ...
  end
end

# -------------------------------- Exercise 1 -------------------------------- #

fun num-rooms(building :: Building) -> Number:
  doc: "Counts the total number of _rooms_ in a building."

  cases(Building) building:
    | ground => 0
    | story(_, rooms, _, below) => rooms + num-rooms(below)
  end
where:
  num-rooms(evg) is 0
  num-rooms(ev1) is 90
  num-rooms(ev2) is 180
  num-rooms(ev3) is 260
  num-rooms(ev4) is 360
  num-rooms(ev5) is 360
  num-rooms(ivg) is 0
  num-rooms(iv1) is 0
  num-rooms(iv2) is 10
end

# -------------------------------- Exercise 2 -------------------------------- #

fun max-rooms(building :: Building) -> Number:
  doc: "Finds the maximum number of rooms in one story within a building."

  cases(Building) building:
    | ground => 0
    | story(_, rooms, _, below) => max(rooms, max-rooms(below))
  end
where:
  max-rooms(evg) is 0
  max-rooms(ev1) is 90
  max-rooms(ev2) is 90
  max-rooms(ev3) is 90
  max-rooms(ev4) is 100
  max-rooms(ev5) is 100
  max-rooms(ivg) is 0
  max-rooms(iv1) is 0
  max-rooms(iv2) is 10
end

# -------------------------------- Exercise 3 -------------------------------- #

fun first-floor(building :: Building) -> Option<Building%(is-story)>:
  doc: "returns the first floow above ground if it exists"

  cases(Building) building:
    | ground => none
    | story(_, _, _, below) =>
      cases(Building) below:
        | ground => some(building)
        | else => first-floor(below)
      end
  end
where:
  first-floor(evg) is none
  first-floor(ev1) is some(ev1)
  first-floor(ev2) is some(ev1)
  first-floor(ev3) is some(ev1)
  first-floor(ev4) is some(ev1)
  first-floor(ev5) is some(ev1)
  first-floor(ivg) is none
  first-floor(iv1) is some(iv1)
  first-floor(iv2) is some(iv1)
end

# -------------------------------- Exercise 4 -------------------------------- #

fun is-unbalanced(building :: Building) -> Boolean:
  doc: "Indicates if there is a story with more rooms than a story below it."

  cases(Building) building:
    | ground => false
    | story(_, rooms-above, _, below) =>
      cases(Building) below:
        | ground => false
        | story(_, rooms-below, _, _) =>
          (rooms-below < rooms-above) or is-unbalanced(below)
      end
  end
where:
  is-unbalanced(evg) is false
  is-unbalanced(ev1) is false
  is-unbalanced(ev2) is false
  is-unbalanced(ev3) is false
  is-unbalanced(ev4) is true
  is-unbalanced(ev5) is true
  is-unbalanced(ivg) is false
  is-unbalanced(iv1) is false
  is-unbalanced(iv2) is true
end
