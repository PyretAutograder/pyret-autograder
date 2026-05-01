
provide: is-valid, oracle end
# END HEADER
#| wheat (tdelvecc, Sep 7, 2020)
    Basic wheat; follows specs without additional features;
    - Raises an error on negative input in generate-input;
    - Raises an error when companies or candidates invalid in is-valid.
|#
# Updated 2022 by srajesh1 to remove generate-input

# shadow set = sets.set
# type Set<T> = sets.Set<T>

fun index-of<A>(lst :: List<A>, ele :: A) -> Number:
  doc: "Finds the index of ele in lst, or raises error if not present."
  cases (List<A>) lst:
    | empty => raise("Did not find element in list.")
    | link(f, r) => 
      if f == ele:
        0
      else:
        1 + index-of(r, ele)
      end
  end
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
end
