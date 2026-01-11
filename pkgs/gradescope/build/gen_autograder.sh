#!/usr/bin/env bash

set -euo pipefail

# NOTE: see pyret-autograder/nix/packages/gradescope-build for how this is used

# Expected Environment:
# - `wrapped-pyret` is in $PATH which pre-sets the needed compiled dirs
# - `makeWrapper` from nix is in $PATH
# - `$AUTOGRADER_IN` is set
# - `/bin/node` exists

# Runtime Expectations:
# - $OUT_DIR structure will be preserved (autograder.jarr will be next to run_autograder)
# - the required runtime node_modules can be resolved (stored at /node_modules)
# - `/bin/node` exists

die() {
  echo "error: $*" >&2
  exit 2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--dir) SPEC_DIR="$2"; shift 2 ;;
    -o|--out) OUT_DIR="$2"; shift 2 ;;
    -h|--help) echo "gen_autograder.sh [-d|--dir SPEC_DIR] [-o|--out OUT_DIR]"; exit 0 ;;
    *) die "Unknown option: $1 (try --help)" ;;
  esac
done

[[ -n "${AUTOGRADER_IN:-}" ]] || die "AUTOGRADER_IN is not set"
[[ -n "${SPEC_DIR:-}" ]] || die "SPEC_DIR is not set. Set it via env or pass -d/--dir."
[[ -d "${SPEC_DIR:-}" ]] || die "SPEC_DIR does not exist or is not a directory: $SPEC_DIR"
[[ -n "$OUT_DIR" ]]  || die "OUT_DIR is not set. Set it via env or pass -o/--out."

RUNTIME_SHARE_PATH="${RUNTIME_SHARE_PATH:-/share/pyret-autograder}"
RUNTIME_OUTPATH="${RUNTIME_OUTPATH:-/autograder}"

# NOTE: we are relying on our custom `file-reset-load-path module specifier which
# lets us import files relative to the CWD rather than the location of the file.
# This allows us to import `"./specification.arr"` in $AUTOGRADER_IN which will
# resolve to $SPEC_DIR/specification.arr when run under `env -C`
env -C "$SPEC_DIR" \
  wrapped-pyret \
    --build-runnable "$AUTOGRADER_IN" \
    --outfile "$OUT_DIR/autograder.jarr" \
    -no-module-eval

echo "Compiled Standalone..."

COMPILED="$RUNTIME_SHARE_PATH/compiled"

makeWrapper /bin/node "$OUT_DIR/run_autograder" \
  --add-flags "$RUNTIME_OUTPATH/autograder.jarr" \
  --set PA_PYRET_LANG_COMPILED_PATH "$COMPILED/lib-compiled:$COMPILED/cpo-compiled"

# TODO: artifacts

chmod +x "$OUT_DIR/run_autograder"
