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
  pyret-lang-lib-a = pyret-lang-patched.override {
    phaseAOnly = true;
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

    cp -r --no-preserve=mode,ownership ${autograder-lib}/compiled/. $SHARE/autograder-lib
    cp -r --no-preserve=mode,ownership ${pyret-lang-lib-a}/build/phaseA/lib-compiled/. $SHARE/pyret-lib
    cp -r --no-preserve=mode,ownership ${pyret-lang-lib-a}/build/phaseA/js/. $SHARE/js
    cp -r --no-preserve=mode,ownership ${pyret-lang-lib-a}/build/phaseA/bundled-node-deps.js $SHARE/
    cp ${pyret-lang-patched}/build/phaseA/pyret.jarr $SHARE/pyret.jarr
    cp ${pyret-lang-patched}/src/js/base/handalone.js $SHARE/handalone.js
    cp ${pyret-lang-patched}/src/scripts/standalone-configA.json $SHARE/standalone-configA.json
    cp ${pyret-lang-patched}/build/phaseA/config.json $SHARE/
    # TODO: `main` isn't a great name for this...
    cp ${pyret-autograder-src}/pkgs/gradescope/src/main.arr $SHARE/main.arr



    # FIXME: we want to have somthing like this:
    # makeWrapper ${lib.getExe nodejs-slim-stripped} $BIN/wrapped-pyret \
    #   --add-flags "$SHARE/pyret.jarr" \
    #   --add-flags "--require-config $SHARE/standalone-configA.json" \
    #   --add-flags "--compiled-read-only-dir $SHARE/pyret-lib" \
    #   --add-flags "--compiled-read-only-dir $SHARE/autograder-lib" \
    #   --add-flags "--standalone-file $SHARE/handalone.js" \
    #   --add-flags "-no-check-mode"

    # TODO: we shouldn't have to ship pyret library node_modules

    NODE_MODULES=$out/node_modules
    mkdir -p $NODE_MODULES
    cp -r --no-preserve=mode,ownership ${buildtime-deps}/node_modules/. $NODE_MODULES


    find $SHARE/autograder-lib -type f -name '*.js' -print0 \
      | xargs -0 grep -lF '/build/workspace-prepared/pkgs/core/' \
      | xargs sed -i "s|/build/workspace-prepared/pkgs/core/|$NODE_MODULES/pyret-autograder/|g"

    # FIXME: see if we can inline npm resolution inside the compiled files.
    # HACK: temporarily we will just copy the pyret source files into node_modules
    mkdir -p $NODE_MODULES/pyret-autograder/
    cp -r ${pyret-autograder-src}/pkgs/core/. $NODE_MODULES/pyret-autograder/
    mkdir -p $NODE_MODULES/pyret-lang/
    cp -r ${pyret-lang-src}/src/ $NODE_MODULES/pyret-lang/
    cp ${pyret-lang-src}/package.json $NODE_MODULES/pyret-lang/
    # HACK: file referenced by the package's `main` should exist
    mkdir -p $NODE_MODULES/pyret-lang/build/phase0
    touch $NODE_MODULES/pyret-lang/build/phase0/main-wrapper.js

    # makeWrapper ${lib.getExe nodejs-slim-stripped} $BIN/wrapped-pyret \
    #   --add-flags "$SHARE/pyret.jarr" \
    #   --add-flags "--builtin-js-dir $NODE_MODULES/pyret-lang/src/js/trove/" \
    #   --add-flags "--builtin-arr-dir $NODE_MODULES/pyret-lang/src/arr/trove/" \
    #   --add-flags "--builtin-js-dir $NODE_MODULES/pyret-autograder/trove/js/" \
    #   --add-flags "--builtin-arr-dir $NODE_MODULES/pyret-autograder/trove/arr/" \
    #   --add-flags "--compiled-read-only-dir $SHARE/pyret-lib" \
    #   --add-flags "--compiled-read-only-dir $SHARE/autograder-lib" \
    #   --add-flags "--standalone-file $SHARE/handalone.js" \
    #   --add-flags "-no-check-mode"


    makeWrapper ${lib.getExe nodejs-slim-stripped} $BIN/wrapped-pyret \
      --add-flags "$SHARE/pyret.jarr" \
      --add-flags "--compiled-read-only-dir $SHARE/pyret-lib" \
      --add-flags "--compiled-read-only-dir $SHARE/autograder-lib" \
      --add-flags "--standalone-file $SHARE/handalone.js" \
      --add-flags "-no-check-mode"

    makeWrapper ${gen-autograder}/bin/gen_autograder.sh $BIN/gen_autograder.sh \
      --set-default AUTOGRADER_IN "$SHARE/main.arr"

    runHook postInstall
  '';
}
