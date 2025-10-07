# this is somewhat pathological
fun first-floor(building :: Building) -> Option<Building%(is-story)> block:
  cases(Building) building:
    | ground => none
    | story(_, _, _, below-1) =>
      cases(Building) below-1:
        | ground => none
        | story(_, _, _, below-2) =>
          cases(Building) below-2:
            | ground => some(below-1)
            | else => first-floor(below-2)
          end
      end
  end
end
