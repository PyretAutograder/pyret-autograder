{
  lib,
  buildNpmPackage,
  nodejs-slim-stripped,
  gnumake,
  pkg-config,
  python3,
  pixman,
  cairo,
  pango,
  nodejs,
  ...
}:
let
  providedNodejs = nodejs;
in
lib.extendMkDerivation {
  constructDrv = buildNpmPackage;
  excludeDrvArgNames = [
    "needsCanvas"
  ];
  extendDrvArgs =
    _finalAttrs:
    {
      nodejs ? providedNodejs,
      needsCanvas ? false,
      disallowedReferences ? lib.optionals (nodejs != nodejs-slim-stripped) [ nodejs ],
      nativeBuildInputs ? [ ],
      buildInputs ? [ ],
      dontNpmBuild ? true,
      npmFlags ? if dontNpmBuild then [ "--ignore-scripts" ] else [ ],
      dontStrip ? false, # buildNpmPackage enabled this by default
      ...
    }:
    let
      canvasNativeBuildInputs = [
        gnumake
        pkg-config
        python3
      ];
      canvasBuildInputs = [
        pixman
        cairo
        pango
      ];
    in
    {
      inherit
        nodejs
        disallowedReferences
        dontNpmBuild
        npmFlags
        dontStrip
        ;

      nativeBuildInputs = nativeBuildInputs ++ lib.optionals needsCanvas canvasNativeBuildInputs;
      buildInputs = buildInputs ++ lib.optionals needsCanvas canvasBuildInputs;
    };
}
