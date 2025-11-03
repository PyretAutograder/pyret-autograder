{
  stdenv,
  pnpm,
  nodejs,
  pyret-autograder-prepared,
}:

stdenv.mkDerivation {
  name = "pawtograder-exec-ts-bundle";
  src = pyret-autograder-prepared;

  nativeBuildInputs = [
    nodejs
    pnpm
  ];

  buildPhase = ''
    set -eu
    pushd pkgs/pawtograder-exec
    pnpm exec rspack build
    popd
  '';

  installPhase = ''
    mkdir -p $out
    cp -r pkgs/pawtograder-exec/dist $out
  '';
}
