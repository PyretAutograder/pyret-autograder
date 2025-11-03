{
  stdenv,
  lib,
  pnpm,
  nodejs,
  pyret-lang-src,
  pyret-autograder-prepared,
}:

let
  filteredSrc = lib.cleanSourceWith {
    src = "${pyret-autograder-prepared}";
    filter = path: type: !(lib.hasInfix "/pkgs/pawtograder-exec/bin" path);
  };
in
stdenv.mkDerivation {
  name = "pawtograder-exec-pyret-main";
  src = filteredSrc;

  nativeBuildInputs = [
    nodejs
    pnpm
  ];

  buildPhase = ''
    set -eu
    pushd pkgs/pawtograder-exec
    pnpm exec pyret \
      --builtin-js-dir ${pyret-lang-src}/src/js/trove/ \
      --program src/main.arr \
      --outfile src/main.cjs \
      --no-check-mode --norun
    popd
  '';

  installPhase = ''
    mkdir -p $out
    cp pkgs/pawtograder-exec/src/main.cjs $out/
  '';
}
