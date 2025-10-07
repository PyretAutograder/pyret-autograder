fun first-floor(building :: Building) -> Option<Building%(is-story)>:
  cases(Building) building:
    | ground => none
    | story(_, _, _, below) =>
      cases(Building) below:
        | ground => some(building)
        | else => first-floor(below)
      end
  end
end
