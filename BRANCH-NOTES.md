# Branch notes: `allow-subr-in-whaff`

54 commits on top of `master` (`558951e`), fully linear. The branch has two
intertwined threads — a **generalization of the autograder's wheat/chaff merge
engine**, and a **suite of 19 example assignments** built and validated against
it — plus supporting infrastructure. This document records the goals and how
each was accomplished.

> Terminology: a *wheat* is a correct alternate implementation (student tests
> must pass against it); a *chaff* is a subtly broken one (student tests must
> catch the bug). "whaff" = wheat-or-chaff.

---

## 1. Central goal — let a wheat/chaff do more than redefine one function

**Problem (master).** The examplar grader merges an alternate implementation
into the student's program and runs the student's tests against it. On `master`
that merge was a **single-function splice**: `replace-fun` used
`make-fun-extractor` + `make-fun-splicer` to pull out *the one function named
`fun-name`* and graft it in. Helpers, multiple redefinitions, and subroutines
were lost; a missing function raised `ai-missing-replacement-fun`. That is the
limitation the branch name encodes (allow **subr**outines **in wh**eats **a**nd
ch**aff**s).

**Solution — `merge-impl-stmts`, a whole-body merge.** Built across
`bd8af78`, `eb26805`, `92c4b34`, `23cef55`, `3dac722`:

- **`pkgs/core/src/common/visitors.arr`** gained `merge-impl-stmts` (+ helpers
  `stmt-top-level-name`, `bind-name`, `strip-top-level-shadow`). It merges *all*
  of the alt's top-level statements into the student's:
  - replace student `fun`s by name;
  - **prepend alt-only helpers** (so they land in the same letrec group as the
    student's functions);
  - keep student statements in their original order;
  - attach the student's `where:` block to the spliced function;
  - strip `shadow` flags on overridden top-level bindings.
  `make-check-filter` was also hardened to unwrap the `Option<String>`
  check-block name, enabling reliable per-function check routing.
- **`pkgs/core/src/common/repl-runner.arr`** rewired `run-with-alternate-impl`
  to rebuild the program from the **student's module header**
  (`_use` / `_provide` / `imports`) + the *merged body*, and deleted
  `replace-fun`. This is the keystone fact the assignment methodology rests on:
  **the merge keeps the student's imports/includes and discards the alt's** — so
  the student/support module owns the data types and imports; the alt contributes
  only functions.
- **`pkgs/core/src/common/tmp-poc.arr`** dropped the now-unreachable
  `ai-missing-replacement-fun` formatting clause.
- **`pkgs/core/src/graders/examplar.arr`** threaded the alt-impl **filename**
  into every result message, so multi-wheat / multi-chaff-per-function output is
  legible (e.g. `…correct implementation (oracle-wheat-2.arr)`).

**Net capability:** a wheat/chaff can now redefine multiple functions and
introduce its own helper functions/constants.

**Known boundary (surfaced in review):** *functions* merge but *data
definitions* do not — an alt's top-level `data` is silently dropped (anything
`stmt-top-level-name` can't name — `data`, `type`, `check` — is invisible to the
merge). This shaped the architecture of the hard assignments: any data type a
wheat/chaff needs must live on the student side and be identical across all of
them.

---

## 2. Bulk of the work — a validated example-assignment suite

**19 assignments** now live under `pkgs/gradescope/examples/`:

> contfracs · docdiff · fact · filesystem · fluid-images · join-lists ·
> map-reduce · median · mst · nile · oracle · sortacle · tour-guide · tower ·
> tower-new · tweesearch1/2/3 · updater

They were **added** first, then **rebuilt from authoritative source**
(`~/src/assignments/…`) once a repeatable methodology emerged.

### The methodology

- `assignment.arr` — self-contained: a complete reference implementation plus
  **per-function `check "<fn>": …` blocks** carrying real tests (never the bogus
  `1 is 1`).
- `assignment-support.arr` — the *given* data types and helpers, `include`d by
  the student program so they survive the merge.
- `spec.arr` — `mk-well-formed` guard + **per-function** wheat/chaff graders
  (replacing the old cross-product mapping that produced uncatchable graders).
- `grading/` — wheats/chaffs header-stripped to bare functions.
- A contfracs-pattern `Dockerfile` (see §3).
- **Invariant verified in production for every assignment:** all wheats pass,
  every chaff is caught.

### Recurring technical problems solved

| Problem | Resolution |
|---|---|
| `import lists/sets as …` **shadows** the implicit context modules | use `lists.` / `sets.` prefixes, or selective `import X from lists` |
| global vs non-global bare names (`map`/`filter`/`fold` global; `all`/`any`/`distinct`/`foldl`/`length`/… not) | selectively import the non-globals the merge keeps from the student |
| **letrec ordering** — a top-level `s-let` splits the group, so prepended alt helpers can't forward-reference later funcs | move value bindings after the function group (oracle, mst) |
| **raising chaffs** crash a check block instead of failing a test | assert the call **inline** so a raise fails one test cleanly |
| alt **data types** can't differ from the student's (merge drops alt data) | host one shared definition student-side: `updater`'s 5-field `Cursor`+`Action`, `mst`'s union-find `Element` |
| **name collisions** when an alt prepends helpers that exist in support | put the full implementation in `assignment.arr` (map-reduce), or keep support helpers **private** (mst's `fynd`/`union`) |
| **renamed-wrapper chaffs** the name-based merge would bypass | inline the bug into the named function (`filesystem` `fynd`, `docdiff` `overlap`) |
| **uncatchable chaffs** | excluded with rationale (`docdiff` `overlap-in-ok` ≡ wheat; `mst` `negative-weights` only observable via randomness) |
| **randomized generators / hangs** | drop property/oracle generators; write stable property tests (`mst` `generate-input` via vertex count + no-self-loops) |
| **shadowing builtins** (`Set`, `list-to-list-set` are global) | don't redefine them (root cause of `mst`'s first failed run) |

### Production results

Each assignment was built, pushed, and graded via `dockrunj` — all wheats pass,
all chaffs caught:

| assignment | graders | assignment | graders |
|---|---|---|---|
| fact | 6/6 | filesystem | 13/13 |
| median | 7/7 | oracle | 13/13 |
| docdiff | 8/8 | map-reduce | 18/18 |
| tower-new | 22/22 | mst | 23/23 |
| | | updater | 24/24 |

(…plus contfracs, fluid-images, tweesearch1/2/3, tour-guide, sortacle, nile,
join-lists, similarly green.) The two hardest — **`updater`** (tree-zipper with a
student-defined `Cursor`, 16 chaffs including stateful ones) and **`mst`**
(union-find with mutable refs, two oracles, randomness, 13 chaffs) — landed at
full marks; `mst` after one iteration to fix a builtin-shadow error.

---

## 3. Infrastructure & housekeeping

- **Build-script centralization** (`9e0364e`): the two byte-identical Docker
  build-patch scripts (`fix-autograder-lib-uris.js`, `patch-jarr.js`) were
  de-duplicated from 15 example dirs into `pkgs/gradescope/build/`; all 15
  Dockerfiles updated to `COPY` from the shared path. Verified by a clean
  `updater` rebuild.
- **Publication / base-image strategy**: examples build `FROM` the **published**
  `pyretautograder/gradescope` base image and **patch it in place** — recompiling
  `repl-runner.arr` with the new `merge-impl-stmts` engine, dropping in updated
  `examplar` / `tmp-poc` / grader sources, repairing corrupted lib URIs
  (`fix-autograder-lib-uris.js`), and clearing the stale `.jarr` cache
  (`patch-jarr.js`). The companion **`default.nix` regex fix** (`.*` → `[^"]*`
  in the URI-rewrite `sed`) corrects the corruption at the source for newly
  nix-built images.
- **examplar prose** (`eb26805`, `0a73e07`): filename threading + lowercase
  "implementation" in result messages.
- **`tower` vs `tower-new`** (`0a296ee`, `4b5e39a`): the original `tower` is
  preserved exactly as on master (its Dockerfile reverted); a parallel
  `tower-new` was built in the current structure to demonstrate it.
- **`pnpm-workspace.yaml`** (`c258c0b`): pnpm 11's `allowBuilds:` placeholder
  scaffold resolved to explicit booleans (build the native/toolchain deps, skip
  the optional `ws` speedups) — a local-dev fix; confirmed not to touch the
  Gradescope path via an `updater` sanity run.

---

## 4. Outcome

- **Engine goal met:** the wheat/chaff merge generalized from single-function
  splice to whole-body merge — wheats/chaffs can redefine multiple functions and
  add subroutines, with student imports/data preserved and per-function test
  routing intact.
- **Validation goal met:** a 19-assignment suite, trivial to very complex, every
  one verified in production with all wheats passing and all chaffs caught —
  both the deliverable and the regression bed for the engine.
- **Boundary documented:** alt `data` definitions don't merge (only
  functions/constants do); the support/merge architecture works around it. A
  "Case A" extension to allow *new, non-colliding* alt data types was scoped
  (feasible, ~½–1 day; the only non-trivial part is checking the included
  support file for collisions, since the merge layer can't see `include`d names)
  and confirmed not to regress any current assignment.

---

## Appendix — file-level change summary (vs `master`)

Core engine:
- `pkgs/core/src/common/visitors.arr` — **add** `merge-impl-stmts` + helpers;
  harden `make-check-filter`.
- `pkgs/core/src/common/repl-runner.arr` — `run-with-alternate-impl` rewritten
  to use `merge-impl-stmts`; `replace-fun` and `ai-missing-replacement-fun`
  removed.
- `pkgs/core/src/common/tmp-poc.arr` — drop the stale error clause.
- `pkgs/core/src/graders/examplar.arr` — thread alt-impl `filename` into result
  prose.

Build / packaging:
- `pkgs/gradescope/build/{fix-autograder-lib-uris,patch-jarr}.js` — **new**,
  shared build-patch scripts.
- `nix/packages/gradescope-build/default.nix` — URI-rewrite `sed` regex fix.
- `pnpm-workspace.yaml` — resolved `allowBuilds`.

Examples: 19 assignments under `pkgs/gradescope/examples/` (see §2); `tower`
unchanged from master except — and including — its reverted Dockerfile.
