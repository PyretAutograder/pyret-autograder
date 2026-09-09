{
  buildNpmPackageCanvas,
  fetchFromGitHub,
  pyret-lang,
  sources,
}:

buildNpmPackageCanvas {
  name = "pyret-npm";

  src = fetchFromGitHub {
    inherit (sources.pyret-npm)
      owner
      repo
      rev
      hash
      ;
  };

  inherit (sources.pyret-npm) npmDepsHash;

  dontNpmBuild = true;
  needsCanvas = true;

  patches = [ ./no-clone.patch ];

  postPatch = ''
    mkdir -p pyret-lang
    cp -r ${
      pyret-lang.override {
        phaseAOnly = true;
      }
    }/. pyret-lang/
  '';

  buildPhase = ''
    set -eu
    runHook preBuild

    pushd pyret-lang
    rm .npmignore
    touch .npmignore
    popd

    runHook postBuild
  '';

  installPhase = ''
    mkdir -p $out
    cp -r . $out
  '';

  # FIXME:
  disallowedReferences = [ ];
}
