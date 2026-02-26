# pyret-autograder-gradescope

This is an adaptor between pyret autograder and Gradescope.

It is designed to use Gradescope's [manual Docker][1] support. Each assignment requires publishing an image to [Docker Hub][2].
It is advised that assignment images are private so students can't inspect the grading implementation.

[1]: https://gradescope-autograders.readthedocs.io/en/latest/manual_docker/
[2]: https://hub.docker.com/

## Overview

The Gradescope adaptor uses a two-stage Docker build:
1. **Build stage**: Compiles your grading specification into a standalone executable
2. **Run stage**: Executes the autograder when students submit assignments

Two Docker images are generated from this project:
- `pyretautograder/gradescope-build`
- `pyretautograder/gradescope-run`

> [!WARNING]
> It is *very* important that the versions of `gradescope-build` and `gradescope-run`
> match! The images are built with nix so the common nix stores must be identical.

## Quick Start

> [!NOTE]
> See the [assignment template](https://github.com/PyretAutograder/gradescope-assignment) to easily get started

Each assignment is expected to have a main pyret file that `provides` a spec

```arr
provide spec

spec = # ...
```

This file should be passed to the `gen_autograder` provided by the `gradescope-build`
image, where it will generate a an executable that gradescope will execute
with each submission.

### example

A minimal autograder example with the following structure:

```
.
├── Dockerfile
└── spec.arr
```

Dockerfile:
```dockerfile
# NOTE: gradescope-build and gradescope-run should be kept in sync
ARG TAG=0.0.1-pre.1

FROM pyretautograder/gradescope-build:${TAG} AS build

COPY spec.arr /in/spec.arr
RUN mkdir /out

RUN gen_autograder -d /in -o /out

FROM pyretautograder/gradescope-run:${TAG} AS run

COPY --from=build /out/. /autograder
```

<!-- TODO: use custom `spec` constructor -->
spec.arr:
```arr
use context autograder-spec
include graders

provide: spec end

spec = [list:

]
```

### Build and Push

Once the assignment specification is complete, one should build the docker image and push it to docker hub.

> [!WARNING]
> Reminder that it is advised that assignment images are private so students can't inspect them.
>
> Unfortunately, Gradescope only supports pulling images from Docker Hub. To use a private image,
> you must grant Gradescope’s Docker Hub account, `gradescopeecs`, access as a collaborator on
> the repository, > which requires a paid Docker Hub plan.

# - Examplar tests grouping

```sh
docker build -t username/repository:tag .
docker push username/repository:tag
```

### Configure Gradescope

Configure the autograder to use "Manual Docker configuration" and enter the dockerhub `username/repository:tag` entered earlier.

## Graders

> [!TIP]
> This autograder is specified using a DAG. See the [top-level README](../../README.md)
> for an overview.
>
> Each grader is a node in said DAG which contains a (unique) `id` and a list
> of `deps`.

> [!CAUTION]
> These APIs are very unstable, it is advisable to use indirect to reduce future
> maintenance burden if using a prerelease.
>
> - Currently all paths are relative to `/autograder/` at runtime,
> 	but this will likely change in the future.

### Guards

The following graders will block further execution if some condition isn't met,
and otherwise do nothing.

```arr
# Checks that the student's code parses and is well-formed.
fun mk-well-formed(
	id :: Id, deps :: List<Id>, filepath :: String
): ... end

# Verifies a function is defined with the correct arity.
fun mk-fn-def(
	id :: Id, deps :: List<Id>, path :: String, fn-name :: String,
	arity :: Number
): ... end

# Verifies a constant is defined.
fun mk-const-def(
	id :: Id, deps :: List<Id>, path :: String, const-name :: String
): ... end

# Ensures students don't use prohibited language features (like mutation).
fun mk-training-wheels(
	id :: Id, deps :: List<Id>, path :: String, top-level-only :: Boolean
): ... end

# Ensures students test with diverse inputs and outputs.
fun mk-test-diversity(
  id :: Id, deps :: List<Id>, path :: String, fn :: String,
	min-in :: Number, min-out :: Number
): ... end
```

### Scorers

The following graders award points based on test results.

```arr
# Tests student implementation against instructor-provided tests.
fun mk-functional(
  id :: Id, deps :: List<Id>, student-path :: String, ref-path :: String,
  check-name :: String, points :: Number, fun-name :: Option<String>
): ... end

# Tests student's tests against a known good implementation.
fun mk-wheat(
  id :: Id, deps :: List<Id>, student-path :: String, alt-impl-path :: String,
  fun-name :: String, points :: Number
): ... end

# Tests student's tests against a known bad implementation.
fun mk-chaff(
  id :: Id, deps :: List<Id>, student-path :: String, alt-impl-path :: String,
  fun-name :: String, points :: Number
): ... end

# Run student's tests against their own code
fun mk-self-test(
  id :: Id, deps :: List<Id>, path :: String, fun-name :: String,
  points :: Number
): ... end
```

### Artifacts

> [!CAUTION]
> Artifact handling is not yet handled/supported for the Gradescope platform.

```arr
fun mk-image-artifact(
  id :: Id, deps :: List<Id>, student-path :: String, generator-path :: String,
  save-to :: String, # this is relative to PA_ARTIFACT_DIR
  name :: String
): ... end
```

## Examples

There are examples in the ./examples directory. Some of these have symlinks to
outside of the docker root, you can run from the project's root directory. Make
sure to use the relevant `build.sh` scripts.

## Building Images (For Maintainers)

From project root:
```sh
$(nix build .#gradescope-build-docker --no-link --print-out-paths) | docker load
$(nix build .#gradescope-run-docker --no-link --print-out-paths) | docker load
```
