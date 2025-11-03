{
  buildNpmPackageCanvas,
  pyret-lang-src,
  phaseAOnly ? false,
}:

buildNpmPackageCanvas {
  name = "pyret-lang";

  src = pyret-lang-src;
  needsCanvas = true;
  npmFlags = [ ];

  npmDepsHash = "sha256-fYR/67nbU9hZTX9K8Oc8IVNe0RylKwJQK7rNwvTMISE=";

  buildPhase =
    if phaseAOnly then
      ''
        make phaseA libA
      ''
    else
      null;

  installPhase = ''
    mkdir -p $out
    cp -r . $out
  '';

  # FIXME:
  disallowedReferences = [ ];
}
