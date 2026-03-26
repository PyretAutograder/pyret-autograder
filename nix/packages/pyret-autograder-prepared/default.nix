{
  stdenv,
  nodejs,
  pnpm,
  pnpmConfigHook,
  fetchPnpmDeps,
  buildNpmPackageCanvas,
  pyret-autograder-src,
  pyret-lang,
  pyret-npm,
  ...
}:
stdenv.mkDerivation (finalAttrs: {
  name = "workspace-prepared";

  src = pyret-autograder-src;

  nativeBuildInputs = [
    nodejs
    pnpm
    pnpmConfigHook
  ]
  ++ buildNpmPackageCanvas.canvasNativeBuildInputs;

  buildInputs = buildNpmPackageCanvas.canvasBuildInputs;

  pnpmDeps = fetchPnpmDeps {
    pname = finalAttrs.name;
    inherit (finalAttrs) src;
    fetcherVersion = 2;
    hash = "sha256-S1/LRLLEcexiwwc4W21SoECmrJ2u3zgt0uaKLtGzmhQ=";
  };

  buildPhase = ''
    set -eu

    runHook preBuild

    pnpm install --offline --frozen-lockfile

    # Replace npm-published pyret-lang and pyret-npm with Nix-built versions
    # (which have additional patches applied for the build environment)
    pyret_lang_dir=$(find node_modules/.pnpm -path '*/@ironm00n/pyret-lang' -type d | head -1)
    pyret_npm_dir=$(find node_modules/.pnpm -path '*/@ironm00n/pyret-npm' -type d | head -1)

    if [ -n "$pyret_lang_dir" ]; then
      echo ">> replacing $pyret_lang_dir with Nix-built pyret-lang"
      rm -rf "$pyret_lang_dir"
      mkdir -p "$pyret_lang_dir"
      cp -r --no-preserve=mode,ownership ${pyret-lang}/. "$pyret_lang_dir/"
    fi

    if [ -n "$pyret_npm_dir" ]; then
      echo ">> replacing $pyret_npm_dir with Nix-built pyret-npm"
      rm -rf "$pyret_npm_dir"
      mkdir -p "$pyret_npm_dir"
      cp -r --no-preserve=mode,ownership ${pyret-npm}/. "$pyret_npm_dir/"
    fi

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r . $out

    runHook postInstall
  '';
})
