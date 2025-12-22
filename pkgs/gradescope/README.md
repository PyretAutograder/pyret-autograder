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
FROM pyretautograder/gradescope-build:0.0.1-pre.1 as build

COPY spec.arr /spec.arr
RUN gen_autograder -d /spec.arr -o ??? # outputs /run_autograder, /compiled.js

FROM pyretautograder/gradescope-run:0.0.1-pre.1 as run
COPY --from=build /compiled.js /autograder/compiled.js
COPY --from=build /run_autograder /autograder/run_autograder
```

spec.arr:
```arr
use context autograder-spec
include graders

provide: spec end

spec = [spec:


]
```

```
printf "use context autograder-spec\nprovide: spec end\nspec = [list:]\n" > specification.arr
gen_autograder.sh -d .
```

