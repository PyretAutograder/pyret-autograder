
provide {hire: hire, is-hire: is-hire, matchmaker: matchmaker, generate-input: generate-input} end
provide-types {Hire :: Hire}
import shuffle from lists


data Hire:
  | hire(company :: Number, candidate :: Number)
end

fun index-of<A>(lst :: List<A>, ele :: A) -> Number:
  doc: ```Finds the index of ele in lst. Raises error if not present.```

  fun helper(shadow lst :: List<A>, cur-index :: Number) -> Number:
    cases (List<A>) lst:
      | empty => raise("Element not found.")
      | link(f, r) =>
        if f == ele:
          cur-index
        else:
          helper(r, cur-index + 1)
        end
    end
  end

  helper(lst, 0)
end

fun generate-input(n :: Number) -> List<List<Number>>:
 doc: ```Returns a list of length n with inner lists of length n, each populated with unique
       elements ranging from 0..n-1```
  reference = range(0, n)
  map(lam(_): shuffle(reference) end, range(0, n))
end


fun matchmaker(companies :: List<List<Number>>, candidates :: List<List<Number>>) -> sets.Set<Hire>:
  doc: ```An implementation of the stable marriage problem. Based on
       https://en.wikipedia.org/wiki/Stable_marriage_problem#Algorithmic_solution.```

  problem-size = companies.length()
  # Keeps track of what companies/candidates are engaged; none when not engaged.
  comp-engagements :: Array<Option<Number>> = array-of(none, problem-size)
  cand-engagements :: Array<Option<Number>> = array-of(none, problem-size)

  fun engage(company :: Number, candidate :: Number) -> Nothing:
    doc: ```Updates engagements to match company with candidate.```
    block:
      comp-engagements.set-now(company, some(candidate))
      cand-engagements.set-now(candidate, some(company))
      nothing
    end
  end

  fun match-a-company(company :: Number, preferences :: List<Number>) -> List<Number>:
    doc: ```Given a company, checks if it's engaged. If it's not, then it proposes
         engagement to the next candidate in their preferences, and updates appropriately.```
    cases (Option<Number>) comp-engagements.get-now(company):
        # When the company is engaged, don't do anything.
      | some(_) => preferences
      | none =>
        cases (List<Number>) preferences block:
          | empty => raise("Company ran out of preferences!")
          | link(candidate, r) =>
            # Check the candidate's current engagement status
            cases (Option<Number>) cand-engagements.get-now(candidate) block:
              | none => 
                # If the candidate is unengaged, then proposal succeeds
                engage(company, candidate)
              | some(other-company) =>
                # Otherwise, check if the current company is an improvement
                let cand-prefs = candidates.get(candidate):
                  when index-of(cand-prefs, company) < index-of(cand-prefs, other-company) block:
                    comp-engagements.set-now(other-company, none)
                    engage(company, candidate)
                  end
                end
            end
            
            # Since the company has proposed to the candidate, take candidate off preference list.
            r
        end
    end
  end

  fun is-eligible(company :: Number) -> Boolean:
    doc: ```Checks whether a given company is currently engaged.```
    is-none(comp-engagements.get-now(company))
  end

  fun produce-answer() -> sets.Set<Hire>:
    doc: ```Takes the current engagements and turns them into a set of hires.```
    for map(company from range(0, problem-size)):
      cases (Option<Number>) comp-engagements.get-now(company):
        | none => raise("Algorithm resulted in unassigned company.")
        | some(candidate) => hire(company, candidate)
      end
    end
      ^ sets.list-to-set
  end

  fun match-help(shadow companies :: List<List<Number>>) -> sets.Set<Hire>:
    doc: ```The main body of matchmaker.```
    if range(0, problem-size).any(is-eligible):
      # Go through companies and have eligible ones propose to next candidates
      map_n(match-a-company, 0, companies)
      # And then recur
        ^ match-help
    else:
      # When all companies are engaged, return
      produce-answer()
    end
  end

  match-help(companies)
end
