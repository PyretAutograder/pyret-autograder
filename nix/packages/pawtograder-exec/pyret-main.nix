{
  stdenv,
  lib,
  nodejs,
  pyret-lang,
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
  ];

  buildPhase = ''
    set -eu
    pushd pkgs/pawtograder-exec

    node ${pyret-lang}/build/phaseA/pyret.jarr \
      --builtin-js-dir ${pyret-lang}/src/js/trove/ \
      --builtin-arr-dir ${pyret-lang}/src/arr/trove/ \
      --standalone-file ${pyret-lang}/src/js/base/handalone.js \
      --build-runnable src/main.arr \
      --outfile src/main.cjs \
      -no-check-mode

    popd
  '';

  installPhase = ''
    mkdir -p $out
    cp pkgs/pawtograder-exec/src/main.cjs $out/
  '';
}
