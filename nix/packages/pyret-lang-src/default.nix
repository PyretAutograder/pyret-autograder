{
  lib,
  stdenv,
  fetchFromGitHub,
  charts-patch ? true,
  symlinks-patch ? true,
  reset-load-path-patch ? false,
  fix-absolute-outfile-patch ? true,
}:

stdenv.mkDerivation {
  name = "pyret-lang-src";

  dontBuild = true;

  # https://github.com/ironm00n/pyret-lang/tree/fork
  src = fetchFromGitHub {
    name = "pyret-lang";
    owner = "ironm00n";
    repo = "pyret-lang";
    rev = "75e29b94ae61c0fef8171414d1743c027444eeb6";
    # sha256 = lib.fakeHash;
    sha256 = "sha256-WFn+FYqqK+D5WeL742oqu+4fCMFYSE8CyPunYYWmpX8=";
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
