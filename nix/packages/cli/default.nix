{
  stdenv,
  lib,
  nodejs-slim-stripped,
  makeWrapper,
  pyret-autograder-prepared,
  nodejs,
  pnpm,
  pawtograder-exec,
  ...
}:
stdenv.mkDerivation (finalAttrs: {
  name = "pyret-autograder-cli";

  src = pyret-autograder-prepared;

  nativeBuildInputs = [
    nodejs
    pnpm
    makeWrapper
  ];

  buildPhase = ''
    set -eu
    pushd pkgs/cli
    pnpm run build
    popd
  '';

  installPhase = ''
    runHook preInstall

    set -eu
    mkdir -p $out/bin

    cp -r pkgs/cli/dist $out/
    cp pkgs/cli/package.json $out/
    cp -rL pkgs/cli/node_modules $out/
    cp ${pawtograder-exec}/bin/pyret-pawtograder $out/bin

    makeWrapper ${lib.getExe nodejs-slim-stripped} $out/bin/cli \
      --add-flags "--enable-source-maps" \
      --add-flags "$out/dist/index.js" \
      --set PAWTOGRADER_PYRET_PATH "$out/bin/pyret-pawtograder"

    runHook postInstall
  '';
})
