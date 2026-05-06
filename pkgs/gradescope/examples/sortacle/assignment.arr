provide: generate-input, is-valid, oracle end

include file("submission/assignment-support.arr")


# END HEADER
#| wheat (tdelvecc, Sep 6, 2020): 
    Basic wheat; follows specs without additional features.
    - ages from [-5e5, 5e5) # updated by blee58 due to underspecification in 2022 handout
    - names random
    - raies an error when n < 0 for generate-input
    - raises error for invalid person
|#

# import range from lists
# import lists as lists

fun generate-input(n :: Number) -> List<Person> block:
  doc: "Generates n random Persons."
  
  when n < 0:
    raise("Invalid n provided.")
  end
  
  fun generate-name(shadow length :: Number) -> String:
    doc: "Generates a random name of given length."
    for lists.map(_ from lists.range(0, length)):
      num-random(65535)
    end
      ^ string-from-code-points
  end
  
  for lists.map(_ from lists.range(0, n)):
    person(
      generate-name(num-random(100)), 
      (num-random(1e6) - 5e5) + (num-random(100) / 100))
  end
  where:

    # shd produce a list of ppl
  for map(num-people from lists.range(0, 11)):
    people = generate-input(num-people)
    for map(individual from people):
      individual satisfies is-person
    end
  end

  # produce list of correct length

  for map(num-people from lists.range(0, 11)):
    people = generate-input(num-people)
    people.length() is num-people
  end

end


fun is-valid(input :: List<Person>, output :: List<Person>) -> Boolean:
  doc: "Checks whether output is a valid sorting of input."
  # The output contains all of the same elements as the input
  (sort-uniquely(input) == sort-uniquely(output)) and
  # and the output is in increasing age order.
  cases (List<Person>) output:
    | empty => true
    | link(_, r) =>
      for lists.all2(left :: Person from output, right from r):
        left.age <= right.age
      end
  end
  where:


  bob = person('Bob', 5)
  frank = person('Frank', 10)
  joe = person('Joe', 5)
  joseph = person('Joe', 7)
  annie = person('Annie', 6)
  will = person('Will', 10)
  alvin = person('Alvin', 4)
  cat = person('Cat', 20)

    # shd identify trivial case lists

  is-valid(empty, empty) is true
  is-valid([list: bob], [list: bob]) is true
  is-valid(empty, [list: bob]) is false
  is-valid([list: bob], empty) is false

  # shd identify lists w/diff numbers of ppl as diff

  is-valid([list: bob], empty) is false
  is-valid(empty, [list: bob]) is false
  is-valid([list: bob, frank], [list: bob]) is false
  is-valid([list: bob, bob, frank], [list: bob, frank]) is false
  is-valid([list: frank, frank, frank], [list: frank]) is false

  # shd identify lists w/diff ppl as diff

  is-valid([list: bob], [list: bob]) is true
  is-valid([list: bob], [list: frank]) is false
  is-valid([list: joe], [list: joseph]) is false
  is-valid([list: bob], [list: joe]) is false
  is-valid([list: bob, bob], [list: bob, bob]) is true
  is-valid([list: bob, bob], [list: bob, joe]) is false
  is-valid([list: bob, bob, joe], [list: bob, joe, joe]) is false
  is-valid([list: joseph, joe], [list: joe, joseph]) is true
  
  # shd identify lists w/diff repetition

  is-valid([list: annie], [list: annie, annie]) is false
  is-valid([list: annie, will, annie, will], [list: annie, will, will, will])
    is false

    # shd identify lists that are sorted correctly

  is-valid([list:],[list:]) is true
  is-valid([list: bob],[list: bob]) is true
  is-valid([list: joseph, bob], [list: bob, joseph]) is true
  is-valid([list: bob, joe, joseph], [list: bob, joe, joseph]) is true
  is-valid([list: bob, joe, joseph], [list: joe, bob, joseph]) is true
  is-valid([list: cat, joseph, joe, bob, alvin], 
    [list: alvin, bob, joe, joseph, cat]) is true
  is-valid([list: joseph, joe, cat, bob, alvin],  
    [list: alvin, joe, bob, joseph, cat]) is true

    # shd identify lists that are sorted incorrectly


  is-valid([list: joseph, bob], [list: joseph, bob]) is false
  is-valid([list: bob, joe, joseph], [list: joseph, bob, joe]) is false
  is-valid([list: bob, joe, joseph], [list: bob, joseph, joe]) is false
  is-valid([list: alvin, bob, joe, joseph, cat], 
    [list: cat, joseph, joe, bob, alvin]) is false
  is-valid([list: joe, joseph, cat, alvin, bob], 
    [list: alvin, bob, cat, joe, joseph]) is false
end


fun oracle(sorter :: (List<Person> -> List<Person>)) -> Boolean:
  doc: "Checks whether sorter is a valid sorter."
  interesting-inputs :: List<List<Person>> = [list:
    [list: ], # empty
    [list: person("A Person", 0)], # one person
    [list: person("A Person", 10), person("B Person", 10)], # two person 1
    [list: person("A Person", 10), person("B Person", 20)], # two person 2
    [list: person("A Person", 20), person("B Person", 10)], # two person 3

    # repeated person
    lists.repeat(20, person("A Person", 5)),
    
    # same name, diff age
    lists.range(0, 10).map(person("A Person", _)), 
    
    # repeat ages, so many valid sorts
    lists.range(0, 100).map({(n): 
        person(
          [list: "A", "B", "C"].get(num-modulo(n, 3)), 
          num-modulo(n, 4))}),
    
    # same age, diff name
    generate-input(10).map({(p): person(p.name, 10)}),
    
    # old people
    generate-input(15).map({(p): person(p.name, p.age + 100000000)}),
    
    # one of a, two of b (in case something with list equivalence is messed up)
    [list: person("a", 20), person("b", 10), person("a", 20)],
    
    # long and reverse sorted
    lists.map2({(p, age): person(p.name, age)}, generate-input(150), lists.range(0, 150))
      .reverse()
  ]
  
  # Manual inputs
  for lists.all(input from interesting-inputs):
    is-valid(input, sorter(input))
  end
  and 
  # Automated inputs
  for lists.all(n from lists.range(3, 30)):
    input = generate-input(n)
    is-valid(input, sorter(input))
  end
  where:

    # outputs True for correct sorting algos

  oracle(correct-sort) is true
  oracle(reverse-then-sort) is true
  oracle(shuffle-then-sort) is true
  oracle(sort-with-mix-ties) is true

  # simpler bad sorting algos that oracle shd output False on
  oracle(empty-list) is false
  oracle(shuffle-sort) is false
  oracle(identity-sort) is false
  oracle(reverse-list) is false
  oracle(swap-sort) is false
  oracle(sort-then-reverse) is false

  # slightly trickier to catch
  oracle(additional-element-front) is false
  oracle(additional-element-end) is false
  oracle(greater-than-10-sort) is false
  oracle(chop-10-sort) is false
  oracle(perturb-names) is false
  oracle(perturb-ages) is false

  # more complex bad sorting algorithms that are unlikely to have been caught
  # by oracles that don't use explicit edge cases
  oracle(bad-if-sorted) is false
  oracle(bad-if-empty) is false
  oracle(delete-dup-sort) is false
  oracle(delete-dup-ages-sort) is false
  oracle(fifty-fifty-sorter) is false
  oracle(sort-ages-not-names) is false

  # specific, possibly hard-to-catch bad sorting algo
  oracle(bad-if-reverse-sorted) is false

end
