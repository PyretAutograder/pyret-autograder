{ stdenv, fetchFromGitHub }:

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

  patches = [
    ./charts.patch
    ./preserve-symlinks.patch
  ];

  installPhase = ''
    mkdir -p $out
    cp -r . $out
  '';
}
