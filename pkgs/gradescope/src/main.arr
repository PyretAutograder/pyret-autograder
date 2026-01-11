# NOTE: this file specifier is CUSTOM! it lets us use the CWD as the `current-load-path`
# rather than the path of the current file.
# See nix/packages/pyret-lang-src/file-reset-load-path-specifier.patch
import spec from file-reset-load-path('./spec.arr')
import grade-specification, write-results, fmt-uncaught-exn from gradescope-support
import either as E

grade-res = cases(E.Either) run-task(lam(): grade-specification(spec).serialize() end):
  | right(exn) => fmt-uncaught-exn(exn)
  | left(val) => val
end

write-results(grade-res)

