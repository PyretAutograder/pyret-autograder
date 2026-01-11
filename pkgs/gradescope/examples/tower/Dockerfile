# NOTE: replace this with `pyretautograder/gradescope` for published versions
ARG PKG_PREFIX=pyret-autograder-gradescope
ARG TAG=0.0.1-pre.1

FROM ${PKG_PREFIX}-build:${TAG} AS build

WORKDIR /in

COPY spec.arr ./spec.arr

RUN gen_autograder -d /in -o /out

FROM ${PKG_PREFIX}-run:${TAG} AS run

WORKDIR /autograder
COPY --from=build /out/. /autograder

