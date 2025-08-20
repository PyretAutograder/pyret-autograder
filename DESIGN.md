# Pyret Autograder Design

## Motivation

Autograders should be mutually beneficial to both students--allowing
instantaneous actionable feedback--and course staff--allowing more energy to be
spent on feedback on design and quality rather than functionality.

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

### Adaptability

- The internal representation of the output of the autograder shouldn't be too
  tightly coupled to the requirements needed for Pawtograder.
- The overall design should be reasonably extensible and relatively well
  documented.

## Core Abstractions

The system is built around a simple but powerful execution model. Each grader 
is represented as a node that can produce one of four outcomes:

```arr
data Outcome:
  | noop
  | emit(res)
  | block(reason)
  | internal-error(err)
end
```

- `noop`: Grader completed with no effect on execution flow (e.g., guard passed)
- `emit`: Grader produced a result (e.g., score, artifact)
- `block`: Prevents downstream graders from running (e.g., code doesn't parse)
- `internal-error`: Something went wrong while running the grader (e.g., invalid config, violated invariant)

This outcome model enables dependency-based execution where graders can specify prerequisites and the system automatically handles blocking, skipping, and error propagation.

Graders are represented as nodes in a directed acyclic graph:

```arr
data Node:
  | node(id, deps, run, ctx)
end
```

Each node has a unique identifier, a list of dependencies (other node IDs), a runner function that produces an outcome, and additional context for result processing.

For a complete understanding of the DAG execution engine, including topological sorting, cycle detection, and dependency resolution, see the implementation in [`src/core.arr`](./src/core.arr).

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
