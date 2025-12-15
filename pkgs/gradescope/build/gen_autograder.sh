#!/usr/bin/env bash

set -euo pipefail

# NOTE: see pyret-autograder/nix/packages/gradescope-build for how this is used

# Expected Environment:
# - `wrapped-pyret` is in $PATH which pre-sets the needed compiled dirs
# - `makeWrapper` from nix is in $PATH
# - `$AUTOGRADER_IN` is set (TODO: how to have this be pointing relative??? solution: --module-load-dir)

# TODO: nice name for what is currently called `main.arr`


while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--dir) SPEC_DIR="$2"; shift 2 ;;
    -h|--help) echo "Usage: $0 [-d|--dir DIR]"; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

RUNTIME_SUBMSSION_DIR="${RUNTIME_SUBMSSION_DIR:-/autograder/submission}"
AUTOGRADER_OUT="${AUTOGRADER_OUT:-/run_autograder}"

# NOTE: we are relying on our custom `file-reset-load-path module specifier which
# lets us import files relative to the CWD rather than the location of the file.
# This allows us to import `"./specification.arr"` in $AUTOGRADER_IN which will 
# resolve to $SPEC_DIR/specification.arr when run under `env -C`
env -C "$SPEC_DIR" \
  wrapped-pyret \
    --build-runnable "$AUTOGRADER_IN" \
    --outfile "$AUTOGRADER_OUT"

# makeWrapper 

# chmod +x /run_autograder
