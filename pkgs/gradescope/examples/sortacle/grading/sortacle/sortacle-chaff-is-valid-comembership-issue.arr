
provide: generate-input, is-valid, oracle end
# END HEADER
#| chaff (tdelvecc, Sep 6, 2020): 
    is-valid only checks that input and output contain same elements
    and length, not frequency of elements. oracle still correct.
    Search "CHAFF DIFFERENCE" for changed code.
|#

# import range from lists
# import lists as lists
# import sets as sets

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
end

fun is-valid(input :: List<Person>, output :: List<Person>) -> Boolean:
  doc: "Checks whether output is a valid sorting of input."
  # CHAFF DIFFERENCE: Only checks co-membership and equal length,
  #                   but not frequency of elements.
  (sets.list-to-set(input) == sets.list-to-set(output)) and
  (input.length() == output.length()) and
  # and the output is in increasing age order.
  cases (List<Person>) output:
    | empty => true
    | link(_, r) =>
      for lists.all2(left :: Person from output, right from r):
        left.age <= right.age
      end
  end
end

fun sort-uniquely(lst :: List<Person>) -> List<Person>:
  doc: "Sorts the given list of people so that therer is only one correct order."
  lst.sort-by(
    {(p1 :: Person, p2 :: Person): 
      (p1.age < p2.age) or ((p1.age == p2.age) and (p1.name < p2.name))},
    {(p1 :: Person, p2 :: Person): p1 == p2})
end


fun oracle(sorter :: (List<Person> -> List<Person>)) -> Boolean:
  doc: "Checks whether sorter is a valid sorter."
  fun is-valid-good(input :: List<Person>, output :: List<Person>) -> Boolean:
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
  end
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
    is-valid-good(input, sorter(input))
  end
  and 
  # Automated inputs
  for lists.all(n from lists.range(3, 30)):
    input = generate-input(n)
    is-valid-good(input, sorter(input))
  end
end

