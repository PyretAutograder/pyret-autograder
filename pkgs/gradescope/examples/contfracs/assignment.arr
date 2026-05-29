provide: take, repeating-stream, threshold, fraction-stream, terminating-stream,
  repeating-stream-opt, threshold-opt, fraction-stream-opt,
  cf-phi, cf-phi-opt, cf-e, cf-e-opt, cf-pi-opt end
# END HEADER

include file("submission/assignment-support.arr")

fun is-repeating-partial-sequence<T>(
    full-stream :: Stream<T>,
    partial-sequence :: List<T>%(is-link),
    times-to-recur :: Number)
  -> Boolean:
  doc: ```Iterates through each sequence of T elements in the given Stream<T>
       full-stream and returns false if that partial sequence's List representation
       does not match the given List<T> partial-sequence; otherwise, recurs on the
       next partial sequence times-to-recur times.```
  sequence-length = partial-sequence.length()
  stream-sequence = take(full-stream, sequence-length)
  if times-to-recur <= 0:
    true
  else if stream-sequence == partial-sequence:
    remaining-sequence = drop(sequence-length, full-stream)
    is-repeating-partial-sequence(remaining-sequence, partial-sequence, times-to-recur - 1)
  else:
    false
  end
  where:
    1 is 1 # bogus test; tested indirectly through the functions that use it
end

fun cf-e-checker<T>(
    remaining-stream :: Stream<T>,
    times-iterated :: Number,
    remaining-iterations :: Number,
    use-option :: Boolean)
  -> Boolean:
  doc: ```Used in tests for cf-e to check that the partial sequences of length
       3 past the first term have the correct values.```
  partial-sequence = take(remaining-stream, 3)
  comparison-list = [list: 1, ((times-iterated + 1) * 2), 1]
  comparison-list-opt = [list: some(1), some((times-iterated + 1) * 2), some(1)]
  if remaining-iterations <= 0:
    true
  else if use-option and (partial-sequence == comparison-list-opt):
    cf-e-checker(drop(3, remaining-stream), times-iterated + 1, remaining-iterations - 1, use-option)
  else if not(use-option) and (partial-sequence == comparison-list):
    cf-e-checker(drop(3, remaining-stream), times-iterated + 1, remaining-iterations - 1, use-option)
  else:
    false
  end
  where:
    1 is 1 # bogus test; tested indirectly through the cf-e checks
end

## Part 1: Streams

fun take<A>(stream :: Stream<A>, n :: Number) -> List<A>:
  doc: "Takes the first n elements from stream."
  ask:
    | n > 0 then: link(lz-first(stream), take(lz-rest(stream), n - 1))
    | n == 0 then: empty
    | n < 0 then: raise("Cannot take negative values.")
  end
  where:
    rec a-stream = lz-link(1, lam(): a-stream end)
    take(a-stream, 0).length() is 0
    take(a-stream, 1).length() is 1
    take(a-stream, 3).length() is 3
    take(a-stream, 5).length() is 5
    take(a-stream, 10).length() is 10
end

fun repeating-stream<A>(original :: List<A>) -> Stream<A> block:
  doc: "Creates a stream which repeats the given list."

  when is-empty(original):
    raise("Cannot make repeating-stream of empty.")
  end

  fun helper(remaining :: List<A>) -> Stream<A>:
    cases (List<A>) remaining:
      | empty => helper(original)
      | link(f, r) => lz-link(f, {(): helper(r)})
    end
  end

  helper(original)
  where:
    neg-ones = repeating-stream([list: -1])
    is-repeating-partial-sequence(neg-ones, [list: -1], 10000) is true
    ones = repeating-stream([list: 1])
    is-repeating-partial-sequence(ones, [list: 1], 10000) is true
    doubles = repeating-stream([list: 1, 2])
    is-repeating-partial-sequence(doubles, [list: 1, 2], 5000) is true
    triples = repeating-stream([list: 1, 2, 3])
    is-repeating-partial-sequence(triples, [list: 1, 2, 3], 3000) is true
end


## Part 2: Options and Terminating Streams

fun terminating-stream<A>(lis :: List<A>) -> Stream<Option<A>>:
  doc: "Creates a stream which starts with some-wrapped lis, then nones."
  cases (List<A>) lis:
    | empty => repeating-stream([list: none])
    | link(f, r) => lz-link(some(f), {(): terminating-stream(r)})
  end
  where:
    is-repeating-partial-sequence(terminating-stream(empty), [list: none], 100) is true
    one-stream = terminating-stream([list: 1])
    lz-first(one-stream) is some(1)
    is-repeating-partial-sequence(lz-rest(one-stream), [list: none], 100) is true
    term5 = terminating-stream([list: 1, 2, 3, 4, 5])
    take(term5, 5) is [list: some(1), some(2), some(3), some(4), some(5)]
    is-repeating-partial-sequence(drop(5, term5), [list: none], 100) is true
end

fun repeating-stream-opt<A>(lis :: List<A>) -> Stream<Option<A>>:
  doc: "Creates a repeating stream of some-wrapped elements of lis."
  lz-map(some, repeating-stream(lis))
  where:
    neg-ones = repeating-stream-opt([list: -1])
    is-repeating-partial-sequence(neg-ones, [list: some(-1)], 100) is true
    ones = repeating-stream-opt([list: 1])
    is-repeating-partial-sequence(ones, [list: some(1)], 100) is true
    doubles = repeating-stream-opt([list: 1, 2])
    is-repeating-partial-sequence(doubles, [list: some(1), some(2)], 500) is true
    fivers = repeating-stream-opt([list: 9, 7, 5, 3, 1])
    is-repeating-partial-sequence(fivers, [list: some(9), some(7), some(5), some(3), some(1)], 500) is true
end


## Hard-coded Continued Fractions

rec cf-phi :: Stream<Number> = lz-link(1, {(): cf-phi})

cf-phi-opt :: Stream<Option<Number>> = lz-map(some, cf-phi)

fun make-e(n :: Number) -> Stream<Number>:
  lz-link(1, {(): lz-link(1, {(): lz-link(n, {(): make-e(n + 2)})})})
  where:
    1 is 1 # bogus test; make-e is an internal helper
end

cf-e :: Stream<Number> = lz-link(2, {(): lz-rest(make-e(2))})

cf-e-opt :: Stream<Option<Number>> = lz-map(some, cf-e)


## Continued-fraction functions

fun fraction-stream-opt(stream :: Stream<Option<Number>>) -> Stream<Option<Number>>:
  doc: ```Creates a stream of fraction approximations from a continued-fraction stream,
          with nones after the last provided coefficient.```
  fun helper(
      prefix :: List<Number>,
      suffix :: Stream<Option<Number>>,
      index :: Number)
    -> Stream<Option<Number>>:
    cases (Option<Number>) lz-first(suffix) block:
      | none => repeating-stream([list: none])
      | some(init-value) =>
        when (init-value <= 0) and (index > 0):
          raise("Coefficients must be strictly positive after 0th.")
        end
        value =
          for fold(value from init-value, item from prefix):
            item + (1 / value)
          end
        lz-link(
          some(value),
          {(): helper(prefix.push(init-value), lz-rest(suffix), index + 1)})
    end
  end
  helper(empty, stream, 0)
  where:
    take(fraction-stream-opt(cf-phi-opt), 5)
      is [list:
      some(1),
      some(1 + (1 / 1)),
      some(1 + (1 / (1 + (1 / 1)))),
      some(1 + (1 / (1 + (1 / (1 + (1 / 1)))))),
      some(1 + (1 / (1 + (1 / (1 + (1 / (1 + (1 / 1))))))))]
    none-frac-stream = fraction-stream-opt(terminating-stream(empty))
    is-repeating-partial-sequence(none-frac-stream, [list: none], 100) is true
    one-frac-stream = fraction-stream-opt(terminating-stream([list: 1]))
    lz-first(one-frac-stream) is some(1)
    is-repeating-partial-sequence(lz-rest(one-frac-stream), [list: none], 100) is true
    beginning-negative = terminating-stream([list: -1, 2])
    take(fraction-stream-opt(beginning-negative), 2) is [list: some(-1), some(-0.5)]
end

fun fraction-stream(coefficients :: Stream<Number>) -> Stream<Number>:
  doc: "Creates a stream of fraction approximations from a continued-fraction stream."
  lz-map(
    {(opt-value :: Option<Number>) -> Number:
      cases (Option<Number>) opt-value:
        | none => raise("Shouldn't reach here.")
        | some(value) => value
      end},
    fraction-stream-opt(lz-map(some, coefficients)))
  where:
    take(fraction-stream(cf-phi), 5)
      is [list:
      1,
      1 + (1 / 1),
      1 + (1 / (1 + (1 / 1))),
      1 + (1 / (1 + (1 / (1 + (1 / 1))))),
      1 + (1 / (1 + (1 / (1 + (1 / (1 + (1 / 1)))))))]
    take(fraction-stream(cf-e), 5)
      is [list:
      2,
      2 + (1 / 1),
      2 + (1 / (1 + (1 / 2))),
      2 + (1 / (1 + (1 / (2 + (1 / 1))))),
      2 + (1 / (1 + (1 / (2 + (1 / (1 + (1 / 1)))))))]
end

fun threshold-opt(approximations :: Stream<Option<Number>>, thresh :: Number) -> Number:
  doc: "Returns the first value in the stream within thresh of the next."
  cases (Option<Number>) lz-first(approximations):
    | none => raise("Threshold too small to approximate")
    | some(first) =>
      cases (Option<Number>) lz-first(lz-rest(approximations)):
        | none => raise("Threshold too small to approximate")
        | some(second) =>
          if num-abs(first - second) < thresh:
            first
          else:
            threshold-opt(lz-rest(approximations), thresh)
          end
      end
  end
  where:
    sample-approx = fraction-stream-opt(repeating-stream-opt([list: 1, 2, 3]))
    approx-a = lz-first(lz-rest(lz-rest(sample-approx)))
    approx-b = lz-first(lz-rest(lz-rest(lz-rest(sample-approx))))
    num-abs(approx-a.value - approx-b.value) < 0.03 is true
    threshold-opt(sample-approx, 0.03) is approx-a.value
    rec none-stream = lz-link(none, lam(): none-stream end)
    threshold-opt(none-stream, 1) raises "Threshold too small to approximate"
    threshold-opt(terminating-stream([list: 1]), 1)
      raises "Threshold too small to approximate"
    terminating-approx = fraction-stream-opt(terminating-stream([list: 1, 2, 3, 4, 5]))
    threshold-opt(terminating-approx, 1) is 1
    threshold-opt(terminating-approx, 0.1) is 1.5
end

fun threshold(approximations :: Stream<Number>, thresh :: Number) -> Number:
  doc: "Returns the first value in the stream within thresh of the next."
  threshold-opt(lz-map(some, approximations), thresh)
  where:
    sample-approx = fraction-stream(repeating-stream([list: 1, 2, 3]))
    approx-a = lz-first(lz-rest(lz-rest(sample-approx)))
    approx-b = lz-first(lz-rest(lz-rest(lz-rest(sample-approx))))
    num-abs(approx-a - approx-b) < 0.03 is true
    threshold(sample-approx, 0.03) is approx-a
    threshold(repeating-stream([list: 1, 2, 1.99999999]), 1) is 2
    threshold(repeating-stream([list: 1, 2, 1.99999999]), 1.000000000000000001) is 1
end

cf-pi-opt :: Stream<Option<Number>> = terminating-stream([list: 3, 7, 15, 1, 292])


## Checks for hard-coded constants

check "cf-phi":
  is-repeating-partial-sequence(cf-phi, [list: 1], 10000) is true
end

check "cf-phi-opt":
  is-repeating-partial-sequence(cf-phi-opt, [list: some(1)], 10000) is true
end

check "cf-e":
  lz-first(cf-e) is 2
  cf-e-checker(lz-rest(cf-e), 0, 3000, false) is true
end

check "cf-e-opt":
  lz-first(cf-e-opt) is some(2)
  cf-e-checker(lz-rest(cf-e-opt), 0, 300, true) is true
end

check "cf-pi-opt":
  take(cf-pi-opt, 5) is [list: some(3), some(7), some(15), some(1), some(292)]
end
