{
  stdenv,
  pyret-autograder-prepared,
  nodejs,
  pyret-lang,
  ...
}:
# Here we are precompiling the builtin modules that we want available for
# specifying assignment specs.
# This allows us to later pass the build-artifacts to `--compiled-read-only-dir`.
stdenv.mkDerivation {
  name = "pyret-dsl-build";
  src = pyret-autograder-prepared;

  nativeBuildInputs = [
    nodejs
  ];

  buildPhase = ''
    set -eu
    pushd pkgs/gradescope/

    mkdir -p compiled

    # NOTE: we intentionally *don't* use `-allow-builtin-overrides` here since
    # none of our custom built-ins should shadow the default ones (atleast for now).
    # FIXME(upstream): should be able to specify /dev/null to outfile
    node ${pyret-lang}/build/phaseA/pyret.jarr \
      --builtin-js-dir ${pyret-lang}/src/js/trove/ \
      --builtin-arr-dir ${pyret-lang}/src/arr/trove/ \
      --standalone-file ${pyret-lang}/src/js/base/handalone.js \
      --builtin-js-dir ./trove/js \
      --builtin-arr-dir ./trove/arr \
      --build-runnable ./trove/include.arr \
      --outfile ignored \
      --compiled-dir ./compiled \
      -no-check-mode

    popd
  '';

  installPhase = ''
    mkdir -p $out
    cp -r pkgs/gradescope/compiled $out/
  '';
}
