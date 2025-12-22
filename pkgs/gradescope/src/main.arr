use context autograder

# NOTE: this file specifier is CUSTOM! it lets us use the CWD as the `current-load-path`
# rather than the path of the current file.
# See nix/packages/pyret-lang-src/file-reset-load-path-specifier.patch
import spec from file-reset-load-path('./specification.arr')



