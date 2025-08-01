# Pyret DCIC Autograder Design

## Motivation

### Testing

At a high level we need to support the following testing:

- validation: checking that the student's implementation run against their own
  provided test
- functional: checking the correctness of a student's _implementation_ based on
  provided instructor tests
- examplar: check the student's _tests_ based on known good (wheats) and bad
  (chaffs) implementations
  - this is achieved by splicing together different ASTs
- other?: there should be a way to test arbitrary conditions for points (aka
  don't overfit our abstractions to just these two cases)

Additionally we should support reasonable weighting as well as zero point tests
and hidden tests (even if pedagogically questionable, can be useful for
diagnostics).

### Feedback

- Error reporting must be excellent for TAs and not misleading for students.
  - ex. a test shouldn't opaquely fail for a student if they made a typo in
    their function name or changed a data definition from the starter code.
  - clear feedback should be given if the student's submission is invalid in
    some way, ex. fails to parse,
  - Associated with a failing test, TAs and course staff should be able to see
    the exact test which failed, the reason it failed, etc.
    - in the case of particularly tricky tests, maybe we should allow a
      description to be written along with the test to describe what it is
      testing?
    - A reach goal would to be able to extract a minimal reproducible example of
      this test failing, and insert a CPO instance allowing for realtime
      debugging with the REPL, etc.
      - this would be especially nifty for examplar tests
- Consider if contract violations should be treated separately from other types
  of errors?
- All tests which the students are graded on should always be visible, even
  if it doesn't actually execute.

### Ease of Grading

- we should be able to produce artifacts from the student's code
  - most notably: rendering images

> [!NOTE] TODO
> Some considerations still need to be made about artifacts:
>
> - likely will also need dependencies
> - what happens if they fail, should these be student visible?
>
> Additionally, we need to determine if there is anything else that the
> autograder could output which would assist in grading (these could even just
> be zero point, hidden tests if needed)

### Adaptability

- The internal representation of the output of the autograder shouldn't be too
  tightly coupled to the requirements needed for Pawtograder.
- The overall design should be reasonably extensible and relatively well
  documented.

## Implementation

### Execution

In order to achieve the design goals of the autograder, it is desirable to be
able to specify that tests have dependencies --- this will greatly up us with
improving error reporting and overall robustness.

In order to do this, the execution of tests are determined by using a DAG using
dependencies.

### Grading

Both ...

> [!NOTE]
> The rationale behind wanting to be able to control the grading separately from the execution is so
>
> - we can easily display debug information to TAs (with REPL in future)
> - different tests should be able to be weighted differently, easily (for example very basic tests might be weighted less than a more involved one)
>
> We need to also ensure that this doesn't result in unreasonable performance penalties.

## Todo

- have a better idea what type of output we want to support
  - should be have a notion of adding line comments or associating tests with
    certain regions of the submission?
  - we've discussed that even if a test is skipped, it should still show up
- incorporate with Pawtograder (consider if it is worth using existing action or not)
  - will require significant coordination with Pawtograder team either way
- refine core data definitions
  - finalize how to represent dependencies (DAG, topological sort?)
  - at its core, it might not be worth differentiating between the different
    types of tests but rather base it off what is returned
    - something like a union of `ran`, `block`, `skipped`?



## Other

We might need to consider how to implement LLM design based feedback (like with
feedbot, but this is likely out of the scope of this project, unless running
multiple autograders doesn't end up being supported)


## Meeting notes

files should be able to run individually


two types of nodes: test and guard
- guard can continue or block
- test can run or skipped

(how to integrate artifacts into this naming?)


```arr
data Result:
  | continue ...
  | block ...
  | run ...
  | skipped ...
  | artifact ...
  | internal-error ...
end
```



## Questions / discussions

- Multiple graders, actions?
  - why is `lint` separate
- Line annotations from autograders
<!-- - what does `part` mean? -->
- instructor only output
  - all output should be able to have granularity
- toggle instructor visibility
- contract violations: yes they should be able to see them...
  - this can be a guard!!! very basic checks
- error visibility maybe should be an option??? guard blocks don't give away much
- multiple files: ex buggy implementations
- CI to check that main autograder refers to valid things
  - have reference "good" and "bad" sample references which run via CI
- what is `extra_data`?

## Jon Meeting

- Api for providing automated feedback
-
