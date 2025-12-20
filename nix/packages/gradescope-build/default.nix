{
  callPackage,
  stdenv,
  lib,
  makeWrapper,
  pyret-lang,
  nodejs-slim-stripped,
  pyret-autograder-src,
  runtime-deps,
  gen_autograder,
}:

let
  autograder-lib = callPackage ./autograder-lib.nix { };
  pyret-lang-lib-a = pyret-lang.override {
    phaseAOnly = true;
  };
  buildtime-deps = runtime-deps.override {
    keep-additional = [ "ws" ];
    # npmDepsHash = lib.fakeHash;
    npmDepsHash = "sha256-fYR/67nbU9hZTX9K8Oc8IVNe0RylKwJQK7rNwvTMISE=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  name = "pyret-autograder-gradescope-build";

  dontUnpack = true;
  nativeBuildInputs = [
    makeWrapper
  ];
  installPhase = ''
    runHook preInstall

    set -eu
    BIN=$out/bin
    mkdir -p $BIN
    SHARE=$out/share/pyret-autograder
    mkdir -p $SHARE

    cp -r ${autograder-lib}/compiled/. $SHARE/autograder-lib
    cp -r ${pyret-lang-lib-a}/build/phaseA/lib-compiled/. $SHARE/pyret-lib
    cp ${pyret-lang}/build/phaseA/pyret.jarr $SHARE/pyret.jarr
    cp ${pyret-lang}/src/js/base/handalone.js $SHARE/handalone.js
    cp -r ${buildtime-deps}/node_modules $out/node_modules

    makeWrapper ${lib.getExe nodejs-slim-stripped} $BIN/wrapped-pyret \
      --add-flags "$SHARE/pyret.jarr" \
      --add-flags "--compiled-read-only-dir $SHARE/pyret-lib" \
      --add-flags "--compiled-read-only-dir $SHARE/autograder-lib" \
      --add-flags "--standalone-file $SHARE/handalone.js" \
      --add-flags "-no-check-mode"

    makeWrapper ${gen_autograder}/bin/gen_autograder.sh $BIN/gen_autograder.sh \
      --set-default AUTOGRADER_IN "${pyret-autograder-src}/pkgs/gradescope/src/main.arr"

    runHook postInstall
  '';
})
