{
  runCommand,
  pyret-autograder-src,
  bash,
}:
runCommand "gen-autograder" { nativeBuildInputs = [ bash ]; } ''
  set -euo pipefail
  mkdir -p $out/bin

  cp ${pyret-autograder-src}/pkgs/gradescope/build/gen_autograder.sh $out/bin/gen_autograder.sh
  chmod +x $out/bin/gen_autograder.sh
  patchShebangs $out/bin/gen_autograder.sh
''
