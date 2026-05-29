provide: take, repeating-stream, threshold, fraction-stream, terminating-stream, repeating-stream-opt, threshold-opt, fraction-stream-opt, cf-phi, cf-phi-opt, cf-e, cf-e-opt, cf-pi-opt end
# END HEADER
#| chaff (tdelvecc, Sep 1, 2020): 
    Defines e incorrectly after 3 coeffs.
    Seach "CHAFF DIFFERENCE" for changed code.
|#

#|
   Generic stream functions
|#

fun take<A>(stream :: Stream<A>, n :: Number) -> List<A>:
  doc: "Takes the first n elements from stream."
  ask:
    | n > 0 then: link(lz-first(stream), take(lz-rest(stream), n - 1))
    | n == 0 then: empty
    | n < 0 then: raise("Cannot take negative values.")
  end
end

fun repeating-stream<A>(original :: List<A>) -> Stream<A> block:
  doc: "Creates a stream which repeates the given list."
  
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
end

fun repeating-stream-opt<A>(lis :: List<A>) -> Stream<Option<A>>:
  doc: "Creates a repeating stream of lis, wrapped in some's."
  lz-map(some, repeating-stream(lis))
end

fun terminating-stream<A>(lis :: List<A>) -> Stream<Option<A>>:
  doc: "Creates a stream which starts with lis, and returns nones after."
  cases (List<A>) lis:
    | empty => repeating-stream([list: none])
    | link(f, r) => lz-link(some(f), {(): terminating-stream(r)})
  end
end


#|
   ContFrac functions
|#

# fraction-stream

fun fraction-stream-opt(stream :: Stream<Option<Number>>) -> Stream<Option<Number>>:
  doc: ```Creates a stream of fractions from a given contfrac stream,
          with nones after the last provided value in stream.```
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
end

fun fraction-stream(stream :: Stream<Number>) -> Stream<Number>:
  doc: "Creates a stream of fractions from a given contfrac stream."
  lz-map({(opt-value :: Option<Number>) -> Number: 
      cases (Option<Number>) opt-value:
        | none => raise("Shouldn't reach here.")
        | some(value) => value
      end},
    fraction-stream-opt(lz-map(some, stream)))
end

# threshold

fun threshold-opt(stream :: Stream<Option<Number>>, max :: Number) -> Number:
  doc: "Returns the first value in stream within max of next value."
  cases (Option<Number>) lz-first(stream):
    | none => raise("Threshold too small to approximate")
    | some(first) =>
      cases (Option<Number>) lz-first(lz-rest(stream)):
        | none => raise("Threshold too small to approximate")
        | some(second) =>
          if num-abs(first - second) < max:
            first
          else:
            threshold-opt(lz-rest(stream), max)
          end
      end
  end
end

fun threshold(stream :: Stream<Number>, max :: Number) -> Number:
  doc: "Returns the first value in stream within max of next value."
  threshold-opt(lz-map(some, stream), max)
end


#|
   Hard-coded ContFracs
|#

rec cf-phi :: Stream<Number> = lz-link(1, {(): cf-phi})
cf-phi-opt :: Stream<Option<Number>> = lz-map(some, cf-phi)

fun make-e(n :: Number) -> Stream<Number>:
  lz-link(1, {(): lz-link(1, {(): lz-link(n, {(): make-e(n + 2)})})})
end
cf-e :: Stream<Number> = lz-link(2, {(): lz-rest(make-e(2))})
# CHAFF DIFFERENCE: Defines e-opt incorrectly after 3 coeffs.
cf-e-opt :: Stream<Option<Number>> = lz-map(some, 
  lz-link(2, {(): lz-link(1, {(): lz-link(2, {(): repeating-stream([list: 2])})})}))

cf-pi-opt :: Stream<Option<Number>> = terminating-stream([list: 3, 7, 15, 1, 292])

