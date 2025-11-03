{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "scc";
  version = "3.6.0";

  src = fetchFromGitHub {
    owner = "boyter";
    repo = "scc";
    rev = "v${version}";
    hash = "sha256-tFhYFHMscK3zfoQlaSxnA0pVuNQC1Xjn9jcZWkEV6XI=";
  };

  patches = [
    ./add-pyret.patch
  ];

  vendorHash = null;

  # scc has a scripts/ sub-package that's for testing.
  excludedPackages = [ "scripts" ];
}
