{
  stdenv,
  pyret-npm,
  pyret-lang,
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
    ./overrides.patch
  ];

  postPatch = ''
    # NOTE: we 'vendor' these because the pnpm.fetchDeps is a fixed-output derivation
    # meaning it can't produce any files referencing store paths
    mkdir -p vendor/pyret-lang vendor/pyret-npm
    cp -r ${pyret-lang}/. vendor/pyret-lang/
    cp -r ${pyret-npm}/. vendor/pyret-npm/

    # these paths are relative to each package.json in pkgs/
    substituteInPlace pnpm-workspace.yaml \
      --replace-fail '@PYRET_LANG@' 'file:../../vendor/pyret-lang' \
      --replace-fail '@PYRET_NPM@'  'file:../../vendor/pyret-npm';
  '';

  installPhase = ''
    mkdir -p $out
    cp -r . $out
  '';
}
