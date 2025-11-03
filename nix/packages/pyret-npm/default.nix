{
  buildNpmPackageCanvas,
  fetchFromGitHub,
  pyret-lang,
}:

buildNpmPackageCanvas {
  name = "pyret-npm";

  # https://github.com/ironm00n/pyret-npm/tree/fork
  src = fetchFromGitHub {
    owner = "ironm00n";
    repo = "pyret-npm";
    rev = "cabdc16c1fa56b93b92e8b72dc98465d875d34df";
    hash = "sha256-t8ag8Za4HWEFMKhJpZwFD1mEvX6hy9IbysMgRZDDaeI=";
  };

  npmDepsHash = "sha256-Lo/BqSK+jMQVpjYi+ZGrOGDSEvPE/jhH6PyrNBpEvMI=";

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
