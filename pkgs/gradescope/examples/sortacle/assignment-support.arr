provide: * end
provide: type * end

data Person:
  | person(name :: String, age :: Number)
end

#### CORRECT IMPLEMENTATIONS

fun correct-sort(input :: List<Person>) -> List<Person>:
  input.sort-by(
    {(shadow a :: Person, shadow b :: Person) -> Boolean: b.age > a.age},
    {(shadow a :: Person, shadow b :: Person) -> Boolean: b.age == a.age})
end

fun reverse-then-sort(input :: List<Person>) -> List<Person>:
  correct-sort(lists.reverse(input))
end

fun shuffle-then-sort(input :: List<Person>) -> List<Person>:
  correct-sort(lists.shuffle(input))
end

fun sort-with-mix-ties(input :: List<Person>) -> List<Person>:
  sorted = correct-sort(input)
  shuffle-same-age(sorted, none)
end


#### INCORRECT IMPLEMENTATIONS

# not a sorting alg, helper function for sort-with-mix-ties
fun shuffle-same-age(input :: List<Person>, prev :: Option<Person>) 
  -> List<Person>:
  cases(Option) prev:
    | none =>
      cases(List) input:
        | empty => empty
        | link(f, r) => shuffle-same-age(r, some(f))
      end
    | some(v) =>
      cases(List) input:
        | empty => link(v, empty)
        | link(f, r) =>
          if f.age == v.age:
            link(f, shuffle-same-age(r, some(v)))
          else:
            link(v, shuffle-same-age(r, some(f)))
          end
      end
  end
end

fun fifty-fifty-sorter(input:: List<Person>) -> List<Person>:
  if num-random(100) > 50:
    sort-then-reverse(input)
  else:
    correct-sort(input)
  end
end

fun shuffle-sort(input :: List<Person>) -> List<Person>:
  lists.shuffle(input)
end

fun identity-sort(input :: List<Person>) -> List<Person>:
  input
end

fun reverse-list(input :: List<Person>) -> List<Person>:
  lists.reverse(input)
end

fun sort-then-reverse(input :: List<Person>) -> List<Person>:
  lists.reverse(correct-sort(input))
end

fun swap-sort(input :: List<Person>) -> List<Person>:
  if input.length() < 2:
    input
  else:
    sorted :: List<Person> = correct-sort(input)
    for fold(output :: List<Person> from sorted,
        idx from lists.range(0, sorted.length() - 1)):
      if num-modulo(idx,2) == 0:
        output.take(idx).append([list: output.get(idx + 1),
            output.get(idx)]).append(output.drop(idx + 2))
      else:
        output
      end
    end
  end
end

fun empty-list(input :: List<Person>) -> List<Person>:
  empty
end

fun additional-element-front(input :: List<Person>) -> List<Person>:
  link(person("Bob", 0), correct-sort(input))
end

fun additional-element-end(input :: List<Person>) -> List<Person>:
  correct-sort(input).append([list: person("God", 10000)])
end

fun perturb-names(input :: List<Person>) -> List<Person>:
  map({(p): person("hacked!! " + p.name, p.age)}, correct-sort(input))
end

fun perturb-ages(input :: List<Person>) -> List<Person>:
  map({(p :: Person): person(p.name, p.age + 1)}, correct-sort(input))
end

fun delete-dup-sort(input :: List<Person>) -> List<Person>:
  correct-sort(lists.distinct(input))
end


fun delete-dup-ages-sort(input :: List<Person>) -> List<Person>:
  correct-sort(lists.foldr(lam(l :: List<Person>, elem :: Person): 
        link(elem, 
        filter(lam(elem2 :: Person): not(elem2.age == elem.age) end, l)) end,
      empty, input))
end

fun chop-10-sort(input :: List<Person>) -> List<Person>:
  sorted = correct-sort(input)
  if (lists.length(sorted) > 10): sorted.take(10)
  else: sorted
  end
end

fun sort-ages-not-names(input :: List<Person>):
  doc: ``` retains names in original order, but sorts ages correctly ```
  map2(
    lam(p1 :: Person, p2 :: Person): person(p1.name, p2.age) end, 
    input,
    correct-sort(input))
end

fun greater-than-10-sort(input :: List<Person>) -> List<Person>:
  doc: ``` fails for lists of 10 or less ```
  sorted = correct-sort(input)
  if (lists.length(sorted) < 11): input
  else: sorted
  end
end

fun bad-if-empty(input :: List<Person>) -> List<Person>:
  doc: ``` fails on empty list ```
  cases (List) input:
    | empty => link(person('fake', 0), empty)
    | link(f, r) =>
      correct-sort(input)
  end
end

fun bad-if-sorted(input :: List<Person>) -> List<Person>:
  doc: ``` fails on input list that is nontrivial (length at least 3)
       and already sorted ```
  cases (List) input:
    | empty => correct-sort(input)
    | link(f, r) =>
      if (input.length() > 2) and list-is-sorted-ascending(input):
        lists.reverse(input)
      else:
        correct-sort(input)
      end
  end
end

fun list-is-sorted-ascending(people :: List<Person>) -> Boolean:
  doc: ```helper for bad-if-sorted```
  cases(List) people:
    | empty => true
    | link(f, r) =>
      cases(List) r:
        | empty => true
        | link(f1, _) => (f.age <= f1.age) and list-is-sorted-ascending(r)
      end
  end
end

fun bad-if-reverse-sorted(input :: List<Person>) -> List<Person>:
  doc: ```fails on input list that is nontrivial (length at least 4) 
       and sorted in descending order```
  if (input.length() >= 4) and list-is-sorted-descending(input):
    input
  else:
    correct-sort(input)
  end
end


fun list-is-sorted-descending(people :: List<Person>) -> Boolean:
  doc: ```helper for bad-if-reverse-sorted```
  cases(List) people:
    | empty => true
    | link(f, r) =>
      cases(List) r:
        | empty => true
        | link(f1, _) => (f.age >= f1.age) and list-is-sorted-descending(r)
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
    
