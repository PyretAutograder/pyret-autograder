{
  stdenv,
  lib,
  nodejs-slim-stripped,
  runtime-deps,
  compiled-builtins,
  makeWrapper,
  callPackage,
  nodejs,
  pnpm,
  ...
}:
let
  pyret-main = callPackage ./pyret-main.nix { };
  ts-bundle = callPackage ./ts-bundle.nix { };
in

stdenv.mkDerivation (finalAttrs: {
  name = "pyret-autograder-pawtograder-exec";

  dontUnpack = true;
  nativeBuildInputs = [
    makeWrapper
  ];
  installPhase = ''
    runHook preInstall

    set -eu
    mkdir -p $out/bin

    cp -r ${ts-bundle}/dist $out/dist
    cp -r ${pyret-main}/main.cjs $out/main.cjs
    cp -r ${runtime-deps}/node_modules $out/node_modules
    ln -s ${compiled-builtins} $out/compiled

    makeWrapper ${lib.getExe nodejs-slim-stripped} $out/bin/pyret-pawtograder \
      --add-flags "--enable-source-maps" \
      --add-flags "$out/dist/main.js" \
      --set PA_PYRET_LANG_COMPILED_PATH "$out/compiled/lib-compiled:$out/compiled/cpo-compiled" \
      --set PYRET_MAIN_PATH "$out/main.cjs"

    runHook postInstall
  '';
})
