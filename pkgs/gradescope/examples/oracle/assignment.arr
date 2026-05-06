provide: is-valid, oracle end

include file("submission/assignment-support.arr")


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
    1 is 1 # bogus test. This is not exported. However, a whaff can replace it.
end


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
