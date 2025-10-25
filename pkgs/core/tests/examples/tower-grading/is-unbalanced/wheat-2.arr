fun is-unbalanced(building :: Building) -> Boolean:
  fun help(shadow building :: Building, prev :: Option<Number>):
    cases(Building) building:
      | ground => false
      | story(_, rooms, _, below) =>
        cases(Option) prev:
          | none => help(below, some(rooms))
          | some(shadow prev) =>
            if rooms < prev:
              true
            else:
              help(below, some(rooms))
            end
        end
    end
  end

  help(building, none)
end
