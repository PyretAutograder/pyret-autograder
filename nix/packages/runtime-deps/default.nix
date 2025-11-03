{
  buildNpmPackageCanvas,
  pyret-lang-src,
  runCommand,
  jq,
  nodejs,
  nodejs-slim-stripped,
  ...
}:
# TODO: should make this a pnpm workspace
let
  keep = [
    "s-expression"
    "q"
    "js-md5"
    "canvas"
    "seedrandom"
    "fast-csv"
    "cross-fetch"
    "source-map"
    "js-sha256"
    "resolve"
    "vega"
    "ascii-table"
  ];
  keepJSON = builtins.toJSON keep;
  src = runCommand "pyret-runtime-deps-src" { nativeBuildInputs = [ jq ]; } ''
    set -euo pipefail
    mkdir -p $out
    keep='${keepJSON}'

    # minimal needed deps from pyret-lang/package.json
    jq --argjson keep "$keep" '
      { name:"pyret-runtime-deps", version:"1.0.0",
        dependencies: ((.dependencies // {}) | with_entries(select(.key as $k | $keep | index($k))))
      }
    ' ${pyret-lang-src}/package.json > $out/package.json

    cp ${pyret-lang-src}/package-lock.json $out/package-lock.json
  '';
in
buildNpmPackageCanvas {
  name = "pyret-runtime-deps";
  inherit src;
  needsCanvas = true;

  # npmDepsHash = lib.fakeHash;
  npmDepsHash = "sha256-fYR/67nbU9hZTX9K8Oc8IVNe0RylKwJQK7rNwvTMISE=";
  npmPruneFlags = [ "--omit=dev" ];

  buildPhase = ''
    runHook preBuild

    # canvas, etc
    npm rebuild

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r node_modules $out/

    # Replace all references to the full nodejs with the slim nodejs
    find $out -type f -exec sed -i \
      "s|${nodejs}/bin/node|${nodejs-slim-stripped}/bin/node|g" {} +

    # HACK: these build artifacts reference node-src
    rm $out/node_modules/canvas/build/canvas.target.mk
    rm $out/node_modules/canvas/build/Makefile
    rm $out/node_modules/canvas/build/config.gypi
    rm -rf $out/node_modules/canvas/build/Release/.deps

    runHook postInstall
  '';
}
