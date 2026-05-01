provide: is-valid, oracle end

# import sets as sets # implicit

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
  where:
    1 is 1
end

fun generate-input(n :: Number) -> List<List<Number>>:
 doc: ```Returns a list of length n with inner lists of length n, each populated with unique
       elements ranging from 0..n-1```
  reference = range(0, n)
  map(lam(_): lists.shuffle(reference) end, range(0, n))
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


#| wheat (tdelvecc, Sep 7, 2020)
    Basic wheat; follows specs without additional features;
    - Raises an error on negative input in generate-input;
    - Raises an error when companies or candidates invalid in is-valid.
|#
# Updated 2022 by srajesh1 to remove generate-input

# import lists as lists
# import sets as sets
# shadow set = sets.set
# type Set<T> = sets.Set<T>

fun l-first<A>(l :: List<A>) -> A:
  doc: "return first element of a list to bypass typechecker"
  cases (List) l:
    | empty => raise("empty list")
    | link(f, r) => f
  end
end



# ==============================
# Incorrect Algorithms
# ==============================

fun make-empty-safe(algo :: (List<List<Number>>, List<List<Number>>
      -> Set<Hire>)) -> 
  (List<List<Number>>, List<List<Number>> -> Set<Hire>):
  doc: "Takes an algorithm and handles the case where both input lists are empty"
  fun safeFun(companies :: List<List<Number>>, 
      candidates :: List<List<Number>>) -> Set<Hire>:
    if (companies == empty) and (candidates == empty):
      empty-list-set
    else:
      algo(companies, candidates)
    end
  end
  safeFun
end

# produces output with too few hires
fun unsafe-too-few-match(companies :: List<List<Number>>, 
    candidates :: List<List<Number>>) -> Set<Hire>:
  input = matchmaker(companies, candidates).to-list() #actually want a list here
  r = random(candidates.length())
  output = for filter(el from input):
    not(r == el.company)
  end
  list-to-set(output)
end
too-few-match = make-empty-safe(unsafe-too-few-match)

# makes a duplicate number -- more than one company hires the same person
fun unsafe-duplicate-match(companies :: List<List<Number>>, 
    candidates :: List<List<Number>>) -> Set<Hire>:
  if candidates.length() <= 2:
    matchmaker(companies, candidates)
  else:
    output = matchmaker(companies, candidates).to-list() #want a list here
    r = random(candidates.length() - 2)
    r2 = r + 1 + random(candidates.length() - -1 - r)
    returnThis = for map(couple from output):
      if couple.company == r:
        hire(r2,r2)
      else:
        couple
      end
    end
    list-to-list-set(returnThis)
  end
end
duplicate-match = make-empty-safe(unsafe-duplicate-match)

# makes a too big number and a negative number
fun unsafe-outofbounds-match(companies :: List<List<Number>>,
    candidates :: List<List<Number>>) -> Set<Hire>:
  output = matchmaker(candidates, companies).to-list() #want a list here
  r = random(candidates.length())
  returnThis = for map(couple from output):
    if couple.company == r:
      hire(-1, candidates.length() + 1)
    else:
      couple
    end
  end
  list-to-set(returnThis)
end
outofbounds-match = make-empty-safe(unsafe-outofbounds-match)

# incorrect when empty lists are passed
fun empty-incorrect-match(companies :: List<List<Number>>, 
    candidates :: List<List<Number>>) -> Set<Hire>:
  if (companies.length() == 0) or (candidates.length() == 0):
    [list-set: hire(0,0)]
  else:
    matchmaker(companies, candidates)
  end
end

# only returns empty
fun empty-match(companies :: List<List<Number>>, 
    candidates :: List<List<Number>>) -> Set<Hire>:
  list-to-set(empty)
end

# only outputs one hire
fun short-matcher(companies :: List<List<Number>>, 
    candidates :: List<List<Number>>) -> Set<Hire>:
  [list-set: hire(0,0)]
end

# matches candidates with their first preference
fun candidates-matcher(companies :: List<List<Number>>, 
    candidates :: List<List<Number>>) -> Set<Hire>:
  cases(List) candidates:
    | empty => empty-list-set
    | link(f, r) => candidates-matcher(r, 
        companies).add(hire(l-first(l-first(candidates)), 
          companies.length() - candidates.length()))
  end
end

# matches 0 with 0, 1 with 1, etc
fun simple-matcher(companies :: List<List<Number>>, 
    candidates :: List<List<Number>>) -> Set<Hire>:
  list-to-set(make-hires(candidates.length() - 1))
end

# returns proper output with one extra element, hire(10, 10)
fun one-added-matcher(companies :: List<List<Number>>,
    candidates :: List<List<Number>>) -> Set<Hire>:
  matchmaker(companies, candidates).add(hire(10, 10))
end

# switches inputs
fun switched-inputs-matcher(companies :: List<List<Number>>,
    candidates :: List<List<Number>>) -> Set<Hire>:
  matchmaker(candidates, companies)
end

# make-hires
fun make-hires(n :: Number) -> List<Hire>:
  if n == -1:
    empty
  else if n == 0:
    link(hire(0,0), empty)
  else:
    link(hire(n,n), make-hires(n - 1))
  end
end

# ==============================
# Test Variables
# ==============================

candidate-tests1 = [list: 
  [list: 2, 3, 1, 0], 
  [list: 1, 2, 0, 3], 
  [list: 0, 2, 1, 3], 
  [list: 2, 1, 0, 3]]
company-tests1 = [list: 
  [list: 2, 3, 1, 0], 
  [list: 3, 2, 0, 1], 
  [list: 1, 3, 0, 2], 
  [list: 0, 1, 2, 3]]
solution1 = [list-set: hire(0, 2), hire(1, 1), hire(2, 3), hire(3, 0)]

sad-companies = [list: [list: 1, 2, 0], [list: 0, 1, 2], [list: 0, 1, 2]]
sad-candidates = [list: [list: 1, 0, 2], [list: 0, 2, 1], [list: 0, 1, 2]]
sad-sol = [list-set: hire(0, 1), hire(1, 0), hire(2, 2)]

#test company input B
test-comp-2 = [list:
  [list: 3, 1, 2, 6, 4, 5, 0],
  [list: 4, 1, 2, 5, 3, 0, 6],
  [list: 1, 2, 3, 4, 5, 6, 0],
  [list: 0, 1, 6, 2, 5, 3, 4],
  [list: 2, 5, 3, 4, 1, 0, 6],
  [list: 0, 1, 3, 2, 4, 6, 5],
  [list: 1, 4, 2, 3, 0, 5, 6]]

#test candidate input B
test-cand-2 = [list:
  [list: 1, 5, 2, 3, 4, 6, 0],
  [list: 2, 4, 3, 5, 1, 0, 6],
  [list: 2, 6, 0, 3, 4, 5, 1],
  [list: 3, 2, 4, 1, 5, 6, 0],
  [list: 1, 0, 2, 3, 4, 5, 6],
  [list: 0, 5, 6, 3, 4, 2, 1],
  [list: 0, 1, 2, 3, 4, 5, 6]]

#stable output B
stable-2 = [list-set: hire(6, 2), hire(5, 0), hire(4, 3), hire(3, 5),
  hire(2, 1), hire(1, 4), hire(0, 6)] 

#unstable output B
unstable-2 = [list-set: hire(0, 3), hire(2, 1), hire(1, 2), hire(3, 0),
  hire(4, 4), hire(5, 5), hire(6, 6)] 

#n too small output B
too-small-2 = [list-set: hire(0, 3), hire(2, 1), hire(1, 2), hire(3, 0),
  hire(4, 4), hire(5, 5)] 

#n too large output B
too-large-2 = [list-set: hire(0, 3), hire(2, 1), hire(1, 2), hire(3, 0),
  hire(4, 4), hire(5, 5), hire(6, 6), hire(7, 7)]

#index too large output B
outofbounds-2 = [list-set: hire(0, 3), hire(2, 1), hire(1, 2), hire(3, 0),
  hire(4, 4), hire(5, 5), hire(7, 7)]

#repeated company B
company-repeat-2 = [list-set: hire(0, 3), hire(2, 1), hire(1, 2), hire(3, 0),
  hire(4, 4), hire(5, 5), hire(0, 7)] 

#repeated candidate B
candidate-repeat-2 = [list-set: hire(0, 3), hire(2, 1), hire(1, 2), hire(3, 0),
  hire(4, 4), hire(5, 5), hire(7, 3)]


fun is-valid(
    companies :: List<List<Number>>,
    candidates :: List<List<Number>>,
    hires :: Set<Hire>)
  -> Boolean block:
  doc: ```Consumes a preference list for each company and candidate
       and a set of Hire's, and produces whether the proposed
       set of Hire's is a valid solution.```

  problem-size = companies.length()
  expected = repeat(problem-size, range(0, problem-size))
  when (companies.map(lists.sort) <> expected) or (candidates.map(lists.sort) <> expected):
    raise("Invalid input.")
  end

  fun is-stable(hire1 :: Hire, hire2 :: Hire) -> Boolean:
    doc: ```Consumes two Hires and produces whether
       the company of hire1 and the candidate of
       hire2 do not both prefer each other over
       their current pairing.```
    company1-preferences = companies.get(hire1.company)
    candidate2-preferences = candidates.get(hire2.candidate)

    # No need to check when same Hire passed in for both
    (hire1 == hire2) or
    # Check if company1 prefers candidate1 over candidate2
    (index-of(company1-preferences, hire1.candidate) < 
      index-of(company1-preferences, hire2.candidate)) or
    # Check if company2 prefers candidate2 over candidate1
    (index-of(candidate2-preferences, hire2.company) <
      index-of(candidate2-preferences, hire1.company))

  end

  num-hires = hires.size()
  hire-list = hires.to-list()

  # Check if each company and candidate are paired exactly once
  # (hence also checking that there are no extra or missing hires)
  (hire-list.map(_.company).sort() == range(0, num-hires)) and
  (hire-list.map(_.candidate).sort() == range(0, num-hires)) and
  # Check number of pairs is correct
  (num-hires == problem-size) and
  # Check every pair of hires is stable
  for lists.all(hire1 from hire-list):
    for lists.all(hire2 from hire-list):
      is-stable(hire1, hire2)
    end
  end
  where:
  # "is-valid:: hard-coded, valid case"
  is-valid(test-comp-2, test-cand-2, stable-2) is true

  # "is-valid:: hard-coded, invalid case - two candidates switched":
  is-valid(test-comp-2, test-cand-2, unstable-2) is false

  #too few output elements
  is-valid(test-comp-2, test-cand-2, too-small-2) is false
  #too many output elements
  is-valid(test-comp-2, test-cand-2, too-large-2) is false

  # "is-valid:: hard-coded, invalid case - element value too large":
  is-valid(test-comp-2, test-cand-2, outofbounds-2) is false

  #repeated company
  is-valid(test-comp-2, test-cand-2, company-repeat-2) is false
  #repeated candidate
  is-valid(test-comp-2, test-cand-2, candidate-repeat-2) is false

  #Empty hires
  is-valid(empty,empty,empty-list-set) is true

  #One person and One company
  is-valid([list: [list: 0]],[list: [list: 0]],[list-set: hire(0,0)]) is true

  #Normal cases
  is-valid(company-tests1, candidate-tests1, solution1) is true
  
  #Adding another correct solution where both a company and candidate prefer others
  is-valid(sad-companies, sad-candidates, sad-sol) is true

  #checks for number of hires(-)
  is-valid(company-tests1, candidate-tests1, [list-set: hire(0,2), hire(1,1), hire(2,3)]) is false 

  #checks for wrong solution
  is-valid(company-tests1, candidate-tests1, [list-set: hire(0, 1), hire(1, 2), hire(2, 3), hire(3, 0)]) is false

  #checks for double hires
  is-valid(company-tests1, candidate-tests1, [list-set: hire(0, 1), hire(1, 1), hire(2, 3), hire(3, 0)]) is false
end

fun oracle(a-matchmaker :: (List<List<Number>>, List<List<Number>> 
      -> Set<Hire>))
  -> Boolean block:
  doc: ```Consumes a purported matchmaking algorithm and
       produces whether it produces the correct output for
       every test case provided.```
  # For size two case
  s0 = [list: 0, 1]
  s1 = [list: 1, 0]

  # For worst case
  fun cycle<A>(lst :: List<A>, n :: Number) -> List<A>:
    parts = lst.split-at(n)
    parts.suffix + parts.prefix
  end

  fun make-worst-case(size :: Number) -> {List<List<Number>>; List<List<Number>>}:
    base = range(0, size)
    companies = range(0, size).map({(n): cycle(base, n)})
    candidates = range(0, size).map({(n): cycle(base, n + 1)})
    {companies; candidates}
  end

  # For best case
  fun make-best-case(size :: Number) -> {List<List<Number>>; List<List<Number>>}:
    base = range(0, size)
    companies = range(0, size).map({(n): cycle(base, n)})
    candidates = companies

    {companies; candidates}
  end

  manual-inputs :: List<{List<List<Number>>; List<List<Number>>}> = [list:
    # Only empty case
    {empty; empty},

    # Only one case
    {[list: [list: 0]]; [list: [list: 0]]},

    # 16 two cases
    {[list: s0, s0]; [list: s0, s0]},
    {[list: s0, s0]; [list: s0, s1]},
    {[list: s0, s0]; [list: s1, s0]},
    {[list: s0, s0]; [list: s1, s1]},
    {[list: s0, s1]; [list: s0, s0]},
    {[list: s0, s1]; [list: s0, s1]},
    {[list: s0, s1]; [list: s1, s0]},
    {[list: s0, s1]; [list: s1, s1]},
    {[list: s1, s0]; [list: s0, s0]},
    {[list: s1, s0]; [list: s0, s1]},
    {[list: s1, s0]; [list: s1, s0]},
    {[list: s1, s0]; [list: s1, s1]},
    {[list: s1, s1]; [list: s0, s0]},
    {[list: s1, s1]; [list: s0, s1]},
    {[list: s1, s1]; [list: s1, s0]},
    {[list: s1, s1]; [list: s1, s1]},

    # Large worst case
    make-worst-case(25),

    # Large best case
    make-best-case(25)
  ]

  # Run against manual tests
  for lists.all({companies; candidates} from manual-inputs):
    is-valid(companies, candidates, a-matchmaker(companies, candidates))
  end and
  # Run against 50 randomly generated situations with sizes 3 to 50.
  for lists.all(problem-size from range(0, 50)):
    companies = generate-input(problem-size)
    candidates = generate-input(problem-size)
    is-valid(companies, candidates, a-matchmaker(companies, candidates))
  end 
  where:
# "oracle-good-solution:: oracle tests (correct solution)":
  oracle(matchmaker) is true

  #matchmaker incorrect when passed empty lists
  oracle(empty-incorrect-match) is false

  #matchmaker only returns empty
  oracle(empty-match) is false

  # too few hires
  oracle(too-few-match) is false

  # duplicate number -- same person hired twice
  oracle(duplicate-match) is false

  # creates out of bounds indexes
  oracle(outofbounds-match) is false

  # only shows hire(0,0)
  oracle(short-matcher) is false

  # matches candidates w/ first pref
  oracle(candidates-matcher) is false

  # matches (0,0), (1,1) etc.
  oracle(simple-matcher) is false

  # adds hire(10, 10)
  oracle(one-added-matcher) is false

  # switches candidates and companies
  oracle(switched-inputs-matcher) is false


end
