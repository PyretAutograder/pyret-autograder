#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")"
PYRET_TROVE_ABS="${REPO_ROOT}/build/_pyret-work/pyret-lang/src/js/trove/"
PYRET_TROVE_REL="$(realpath --relative-to="$REPO_ROOT" "$PYRET_TROVE_ABS")"

env -C $REPO_ROOT rm -rf .pyret/ src/pawtograder.cjs
env -C $REPO_ROOT npx --no pyret -- --shutdown
env -C $REPO_ROOT npx --no pyret -- --shutdown

env -C $REPO_ROOT npx --no pyret -- \
  --builtin-js-dir "$PYRET_TROVE_REL" \
  --program src/pawtograder.arr \
  --outfile src/pawtograder.cjs \
  --no-check-mode --norun
