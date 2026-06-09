ARG PKG_PREFIX=pyretautograder/gradescope
ARG TAG=0.0.1-pre.1
ARG BASE=./pkgs/gradescope/examples/map-reduce

FROM ${PKG_PREFIX}-build:${TAG} AS build
ARG BASE

# Step 1: Fix broken URIs in autograder-lib so the flatness checker
# can find modules correctly when repl-runner.arr is recompiled from source.
COPY pkgs/gradescope/build/fix-autograder-lib-uris.js /fix-autograder-lib-uris.js
RUN node /fix-autograder-lib-uris.js

# Step 2: Delete repl-runner.arr from autograder-lib so it recompiles
# from source (which imports visitors.arr at the nix store URI, not the
# old build-sandbox URI pointing to the autograder-lib's stale copy).
RUN rm -f /nix/store/bsb1zjvp31k4xq0g57k7k6pwqmp1cwdh-pyret-autograder-gradescope-build/share/pyret-autograder/autograder-lib/repl-runner.arr-*

# Step 3: COPY our updated visitors.arr and repl-runner.arr into node_modules.
# gen_autograder recompiles repl-runner.arr from source (the autograder-lib
# precompiled hash c0901aba does not match the nix-store URI hash e744d8aa,
# so it falls through to source compilation).  The published repl-runner.arr
# in node_modules uses make-fun-splicer (old API); our version uses
# merge-impl-stmts which includes ALL alt-impl stmts (gen-rand included).
# visitors.arr must export merge-impl-stmts so repl-runner can import it.
COPY pkgs/core/src/common/visitors.arr \
     /nix/store/bsb1zjvp31k4xq0g57k7k6pwqmp1cwdh-pyret-autograder-gradescope-build/node_modules/pyret-autograder/src/common/visitors.arr
COPY pkgs/core/src/common/repl-runner.arr \
     /nix/store/bsb1zjvp31k4xq0g57k7k6pwqmp1cwdh-pyret-autograder-gradescope-build/node_modules/pyret-autograder/src/common/repl-runner.arr

# Step 4: Copy updated local grader source files to node_modules.
# The published Docker image ships older versions of some grader modules that
# are missing data variants (e.g. too-few-outputs, found-mutation, is-not-wf).
# Copying repl-runner.arr (Step 3) triggers a deeper flatness analysis that
# reaches these modules; without the updated variants the flatness checker
# fails.  Our local git sources have the correct newer versions.
# common/ dependencies imported by the grader files above
COPY pkgs/core/src/common/ast.arr \
     /nix/store/bsb1zjvp31k4xq0g57k7k6pwqmp1cwdh-pyret-autograder-gradescope-build/node_modules/pyret-autograder/src/common/ast.arr
COPY pkgs/core/src/common/markdown.arr \
     /nix/store/bsb1zjvp31k4xq0g57k7k6pwqmp1cwdh-pyret-autograder-gradescope-build/node_modules/pyret-autograder/src/common/markdown.arr
COPY pkgs/core/src/common/tmp-poc.arr \
     /nix/store/bsb1zjvp31k4xq0g57k7k6pwqmp1cwdh-pyret-autograder-gradescope-build/node_modules/pyret-autograder/src/common/tmp-poc.arr
# examplar.arr: our local version threads a `filename` parameter into the
# wheat/chaff diagnostic prose (capital "Implementation (<file>.arr)").  The
# published image ships the old prose, so without this copy the test names and
# messages in results.json never reflect these edits.
COPY pkgs/core/src/graders/examplar.arr \
     /nix/store/bsb1zjvp31k4xq0g57k7k6pwqmp1cwdh-pyret-autograder-gradescope-build/node_modules/pyret-autograder/src/graders/examplar.arr
# updated grader files with newer data variants (is-too-few-outputs etc.)
COPY pkgs/core/src/graders/test-diversity.arr \
     /nix/store/bsb1zjvp31k4xq0g57k7k6pwqmp1cwdh-pyret-autograder-gradescope-build/node_modules/pyret-autograder/src/graders/test-diversity.arr
COPY pkgs/core/src/graders/training-wheels.arr \
     /nix/store/bsb1zjvp31k4xq0g57k7k6pwqmp1cwdh-pyret-autograder-gradescope-build/node_modules/pyret-autograder/src/graders/training-wheels.arr
COPY pkgs/core/src/graders/well-formed.arr \
     /nix/store/bsb1zjvp31k4xq0g57k7k6pwqmp1cwdh-pyret-autograder-gradescope-build/node_modules/pyret-autograder/src/graders/well-formed.arr
COPY pkgs/core/src/graders/const-def.arr \
     /nix/store/bsb1zjvp31k4xq0g57k7k6pwqmp1cwdh-pyret-autograder-gradescope-build/node_modules/pyret-autograder/src/graders/const-def.arr
COPY pkgs/core/src/graders/fn-def.arr \
     /nix/store/bsb1zjvp31k4xq0g57k7k6pwqmp1cwdh-pyret-autograder-gradescope-build/node_modules/pyret-autograder/src/graders/fn-def.arr
COPY pkgs/core/src/graders/self-test.arr \
     /nix/store/bsb1zjvp31k4xq0g57k7k6pwqmp1cwdh-pyret-autograder-gradescope-build/node_modules/pyret-autograder/src/graders/self-test.arr

COPY ${BASE}/spec.arr /in/spec.arr
RUN mkdir /out

RUN gen_autograder -d /in -o /out

COPY pkgs/gradescope/build/patch-jarr.js /patch-jarr.js
RUN node /patch-jarr.js /out/autograder.jarr

FROM ${PKG_PREFIX}-run:${TAG} AS run
ARG BASE

COPY --from=build /out/. /autograder
COPY ${BASE}/grading /autograder/
