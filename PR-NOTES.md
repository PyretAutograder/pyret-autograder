# Generalize the wheat/chaff merge engine; add a validated 19-assignment example suite

## Summary

This branch does two things:

1. **Generalizes the examplar autograder's wheat/chaff merge** from a
   single-function splice to a whole-body merge (`merge-impl-stmts`), so an
   alternate implementation (wheat/chaff) may redefine **multiple functions and
   introduce its own helper subroutines** — not just override one named
   function.
2. **Adds and validates 19 example assignments** that exercise the new engine
   end-to-end; every one builds, deploys, and grades with **all wheats passing
   and all chaffs caught**.

## Motivation

Previously a wheat/chaff could only replace the single function under test
(`replace-fun` → `make-fun-extractor`/`make-fun-splicer`), and a missing
function raised `ai-missing-replacement-fun`. Real assignments need alternates
that add helpers, use subroutines, and redefine several functions at once. The
example suite both demonstrates and regression-tests that capability.

## What changed

### Core engine
- **`common/visitors.arr`** — add `merge-impl-stmts` (+ `stmt-top-level-name`,
  `bind-name`, `strip-top-level-shadow`). It merges all alt statements into the
  student program: replace student `fun`s by name, prepend alt-only helpers
  (same letrec group), preserve student order, attach the student's `where:`
  block to the spliced function, strip top-level `shadow` flags. Harden
  `make-check-filter` to unwrap the `Option<String>` check-block name.
- **`common/repl-runner.arr`** — `run-with-alternate-impl` rebuilds the program
  from the **student's** module header (`_use`/`_provide`/`imports`) + the merged
  body; `replace-fun` and the `ai-missing-replacement-fun` error removed.
- **`common/tmp-poc.arr`** — drop the now-unreachable error-formatting clause.
- **`graders/examplar.arr`** — thread the alt-impl filename into result messages
  so multi-wheat/multi-chaff-per-function output is distinguishable.

### Examples (`pkgs/gradescope/examples/`)
19 assignments, each: a self-contained `assignment.arr` (reference impl +
per-function `check "<fn>":` blocks), shared types/helpers in
`assignment-support.arr`, `spec.arr` with **per-function** wheat/chaff graders,
header-stripped `grading/` files, and a Dockerfile that builds against the
published base image.

> contfracs · docdiff · fact · filesystem · fluid-images · join-lists ·
> map-reduce · median · mst · nile · oracle · sortacle · tour-guide · tower ·
> tower-new · tweesearch1/2/3 · updater

`tower` is left identical to `master`; `tower-new` is the same assignment rebuilt
in the current structure.

### Infrastructure
- **`pkgs/gradescope/build/{fix-autograder-lib-uris,patch-jarr}.js`** — shared
  build-patch scripts, de-duplicated out of 15 example dirs.
- **`nix/.../gradescope-build/default.nix`** — fix the URI-rewrite `sed` regex
  (`.*` → `[^"]*`) so it stops swallowing the opening quote / nix prefix.
- **`pnpm-workspace.yaml`** — resolve pnpm 11's `allowBuilds:` placeholders to
  explicit booleans (local-dev only; no effect on the deployed grader).

## Testing

Every example was built, pushed, and graded via `dockrunj` (build → push →
run → inspect `results.json`). Representative results — wheats all pass, chaffs
all caught:

| assignment | result | assignment | result |
|---|---|---|---|
| fact | 6/6 | filesystem | 13/13 |
| median | 7/7 | oracle | 13/13 |
| docdiff | 8/8 | map-reduce | 18/18 |
| tower-new | 22/22 | mst | 23/23 |
| | | updater | 24/24 |

The hardest cases validate the new engine most directly: **`updater`** (a
tree-zipper with a student-defined `Cursor`; 16 chaffs incl. stateful ones) and
**`mst`** (union-find with mutable refs, two oracles, randomness; 13 chaffs).

## Notes for reviewers

- **The merge keeps the student's module header and discards the alt's.** The
  rebuilt program uses the student's `imports`/`include`s; an alt's own
  imports/provides are dropped. Hence shared data types and selective imports
  live in `assignment.arr` / `assignment-support.arr`, not in the wheat/chaff.
- **Functions merge; `data` definitions do not.** An alt's top-level `data` is
  silently dropped (`stmt-top-level-name` returns `none` for it). So any data
  type a wheat/chaff uses must be defined student-side and be identical across
  all of them. A follow-up ("Case A") could allow *new, non-colliding* alt data
  types; it was scoped (small, with a conservative support-file collision check)
  and confirmed not to regress any current example, but is **not** in this PR.
- **Behavior change worth flagging:** a spec that points a `mk-wheat`/`mk-chaff`
  at a function the alt file doesn't define no longer errors
  (`ai-missing-replacement-fun` is gone) — the merge simply keeps the student's
  version. Well-formed specs are unaffected.
- **Deployment:** examples build `FROM` the published `pyretautograder/gradescope`
  base image and patch updated core sources into it at build time (recompiling
  `repl-runner` with the new engine, repairing lib URIs, clearing the `.jarr`
  cache). The `default.nix` regex fix corrects the same corruption at the source
  for newly nix-built base images.

## Out of scope / follow-ups
- Allowing alt-impl `data` definitions to merge ("Case A"/"Case B").
- Replacing the published-image in-place patching with a freshly built base
  image once the engine changes are released.
