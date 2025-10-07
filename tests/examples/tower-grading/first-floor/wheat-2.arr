fun first-floor(building :: Building) -> Option<Building%(is-story)>:
  fun help(shadow building :: Building, acc :: Option<Building%(is-story)>):
    cases(Building) building:
      | ground => acc
      | story(_, _, _, below) => help(below, some(building))
    end
  end

  help(building, none)
end

