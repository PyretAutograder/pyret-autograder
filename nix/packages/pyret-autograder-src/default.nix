{
  stdenv,
  lib,
  ...
}:

stdenv.mkDerivation {
  name = "pyret-autograder-src";

  src = lib.fileset.toSource {
    root = ../../../.;
    fileset = lib.fileset.unions [
      ../../../pkgs/.
      ../../../pnpm-lock.yaml/.
      ../../../pnpm-workspace.yaml/.
    ];
  };
  dontBuild = true;

  patches = [
    # Skip @ironm00n/pyret-lang build script — we replace it with the Nix-built version post-install
    ./skip-pyret-lang-build.patch
  ];

  installPhase = ''
    mkdir -p $out
    cp -r . $out
  '';
}
