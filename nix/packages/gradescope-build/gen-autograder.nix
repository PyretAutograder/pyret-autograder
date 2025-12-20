{ runCommand, pyret-autograder-src }:
runCommand "gen-autograder" { nativeBuildInputs = [ ]; } ''
  set -euo pipefail
  mkdir -p $out/bin

  cp ${pyret-autograder-src}/pkgs/gradescope/build/gen_autograder.sh $out/bin/gen_autograder.sh
  chmod +x $out/bin/gen_autograder.sh
''
