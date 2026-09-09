{
  lib,
  stdenv,
  fetchFromGitHub,
  sources,
  charts-patch ? true,
  symlinks-patch ? true,
  reset-load-path-patch ? false,
  fix-absolute-outfile-patch ? true,
  trust-read-only-compiled-patch ? true,
  relocatable-npm-uris-patch ? true,
}:

stdenv.mkDerivation {
  name = "pyret-lang-src";

  dontBuild = true;

  src = fetchFromGitHub {
    name = "pyret-lang";
    inherit (sources.pyret-lang)
      owner
      repo
      rev
      hash
      ;
  };

  patches =
    [ ]
    ++ lib.optionals charts-patch [
      ./charts.patch
    ]
    ++ lib.optionals symlinks-patch [
      ./preserve-symlinks.patch
    ]
    ++ lib.optionals reset-load-path-patch [
      ./file-reset-load-path-specifier.patch
    ]
    ++ lib.optionals fix-absolute-outfile-patch [
      ./outfile-absolute.patch
    ]
    ++ lib.optionals trust-read-only-compiled-patch [
      ./trust-read-only-compiled.patch
    ]
    ++ lib.optionals relocatable-npm-uris-patch [
      ./relocatable-npm-uris.patch
    ];

  # reset-load-path shifts later patches to an offset; don't ship .orig litter
  patchFlags = [
    "-p1"
    "--no-backup-if-mismatch"
  ];

  installPhase = ''
    mkdir -p $out
    cp -r . $out
  '';

  passthru = {
    # npmDepsHash = lib.fakeHash;
    npmDepsHash = "sha256-fYR/67nbU9hZTX9K8Oc8IVNe0RylKwJQK7rNwvTMISE=";
  };
}
