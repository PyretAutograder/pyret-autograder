{
  callPackage,
  stdenv,
  lib,
  makeWrapper,
  pyret-lang,
  pyret-lang-src,
  nodejs-slim-stripped,
  pyret-autograder-src,
  runtime-deps,
}:

let
  autograder-lib = callPackage ./autograder-lib.nix { };
  gen-autograder = callPackage ./gen-autograder.nix { };
  pyret-lang-lib-a = pyret-lang.override {
    phaseAOnly = true;
  };
  buildtime-deps = runtime-deps.override {
    keep-additional = [ "ws" ];
    # npmDepsHash = lib.fakeHash;
    npmDepsHash = "sha256-fYR/67nbU9hZTX9K8Oc8IVNe0RylKwJQK7rNwvTMISE=";
  };
  pyret-lang-patched = pyret-lang.override {
    pyret-lang-src = pyret-lang-src.override {
      reset-load-path-patch = true;
    };
  };
in
stdenv.mkDerivation {
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
    cp ${pyret-lang-patched}/build/phaseA/pyret.jarr $SHARE/pyret.jarr
    cp ${pyret-lang}/src/js/base/handalone.js $SHARE/handalone.js
    cp ${pyret-lang}/src/scripts/standalone-configA.json $SHARE/standalone-configA.json
    # TODO: rename
    cp ${pyret-autograder-src}/pkgs/gradescope/src/main.arr $SHARE/main.arr
    cp -r --no-preserve=mode,ownership ${buildtime-deps}/node_modules $out/node_modules
    # FIXME: see if we can inline npm resolution inside the compiled files.
    mkdir -p $out/node_modules/pyret-autograder/
    cp -r ${pyret-autograder-src}/pkgs/core/. $out/node_modules/pyret-autograder/

    makeWrapper ${lib.getExe nodejs-slim-stripped} $BIN/wrapped-pyret \
      --add-flags "$SHARE/pyret.jarr" \
      --add-flags "--require-config $SHARE/standalone-configA.json" \
      --add-flags "--compiled-read-only-dir $SHARE/pyret-lib" \
      --add-flags "--compiled-read-only-dir $SHARE/autograder-lib" \
      --add-flags "--standalone-file $SHARE/handalone.js" \
      --add-flags "-no-check-mode"

    makeWrapper ${gen-autograder}/bin/gen_autograder.sh $BIN/gen_autograder.sh \
      --set-default AUTOGRADER_IN "$SHARE/main.arr"

    runHook postInstall
  '';
}
