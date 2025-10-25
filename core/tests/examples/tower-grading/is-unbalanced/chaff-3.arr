fun is-unbalanced(building :: Building) -> Boolean:
  cases(Building) building:
    | ground => true
    | story(_, rooms-above, _, below) =>
      cases(Building) below:
        | ground => true
        | story(_, rooms-below, _, _) =>
          (rooms-below >= rooms-above) and is-unbalanced(below)
      end
  end
end
