# pyret-autograder-gradescope

This is an adaptor between pyret autograder and Gradescope.

It is designed to use Gradescope's [manual Docker][1] support. Each assignment requires publishing an image to [Docker Hub][2].
It is advised that assignment images are private so students can't inspect 

[1]: https://gradescope-autograders.readthedocs.io/en/latest/manual_docker/
[2]: https://hub.docker.com/

## images

Two Docker images are generated from this project:
- pyretautograder/gradescope-build
- pyretautograder/gradescope-run


> [!WARN]
> It is *very* important that the versions of `gradescope-build` and `gradescope-run`
> match! The images are built with nix so the common nix stores must be identical.

## setup

Each assignment is expected to have a main pyret file that `provides` a spec

```arr
provide spec

spec = # ...
```

This file should be passed to the `gen_autograder` provided by the `gradescope-build`
image, where it will generate a 

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

RUN gen_autograder -d /in -o /out

FROM pyretautograder/gradescope-run:${TAG} AS run

COPY --from=build /out/. /autograder
```

spec.arr:
```arr
use context autograder-spec
include graders

provide: spec end

# TODO: use custom `spec` constructor
spec = [list:


]
```

## Building

From project root:
```sh
$(nix build .#gradescope-build-docker --no-link --print-out-paths) | docker load
$(nix build .#gradescope-run-docker --no-link --print-out-paths) | docker load
```

## Examples

There are examples in the ./examples directory. Some of these have symlinks to outside of the docker root, you can run from the project's root directory.

```sh

```
