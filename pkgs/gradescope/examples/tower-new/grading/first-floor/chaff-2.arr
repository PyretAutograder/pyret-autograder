fun first-floor(building :: Building) -> Option<Building%(is-story)> block:
  # return the second from the ground
  cases(Building) building:
    | ground => none
    | story(_, _, _, below-1) =>
      cases(Building) below-1:
        | ground => none
        | story(_, _, _, below-2) =>
          cases(Building) below-2:
            | ground => some(building)
            | else => first-floor(below-1)
          end
      end
  end
end

