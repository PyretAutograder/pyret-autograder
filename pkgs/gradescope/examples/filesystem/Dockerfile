# NOTE: replace this with `pyretautograder/gradescope` for published versions
# ARG PKG_PREFIX=pyret-autograder-gradescope
ARG PKG_PREFIX=pyretautograder/gradescope
ARG TAG=0.0.1-pre.1
ARG BASE=./pkgs/gradescope/examples/filesystem

FROM ${PKG_PREFIX}-build:${TAG} AS build
ARG BASE

COPY ${BASE}/spec.arr /in/spec.arr
RUN mkdir /out

RUN gen_autograder -d /in -o /out

FROM ${PKG_PREFIX}-run:${TAG} AS run
ARG BASE

COPY --from=build /out/. /autograder
COPY ${BASE}/grading /autograder/
