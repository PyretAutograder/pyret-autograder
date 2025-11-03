{ stdenv, fetchFromGitHub, ... }:

stdenv.mkDerivation {
  name = "cpo-src";

  dontBuild = true;

  # https://github.com/ironm00n/code.pyret.org/tree/fork
  src = fetchFromGitHub {
    name = "cpo";
    owner = "ironm00n";
    repo = "code.pyret.org";
    rev = "f8d41a1e33d57cd79ba03608600701a37ed68e75";
    # hash = lib.fakeHash;
    hash = "sha256-1HRkt0t6+nAwQuKOQMDqo/9xApRjJ7dRvhBhwJj09fo=";
  };

  patches = [
    ./dcic2024-charts.patch
  ];

  installPhase = ''
    mkdir -p $out
    cp -r . $out
  '';
}
