fun is-unbalanced(building :: Building) -> Boolean:
  cases(Building) building:
    | ground => false
    | story(height-above, _, _, below) =>
      cases(Building) below:
        | ground => false
        | story(height-below, _, _, _) =>
          (height-below < height-above) or is-unbalanced(below)
      end
  end
end
