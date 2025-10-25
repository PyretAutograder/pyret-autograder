fun is-unbalanced(building :: Building) -> Boolean:
  cases(Building) building:
    | ground => false
    | story(_, rooms-above, _, below) =>
      cases(Building) below:
        | ground => false
        | story(_, rooms-below, _, _) =>
          (rooms-below < rooms-above) or is-unbalanced(below)
      end
  end
end
