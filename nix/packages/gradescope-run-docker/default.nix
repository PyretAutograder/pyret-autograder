{
  dockerTools,
  runCommand,
  nodejs-slim-stripped,
  runtime-deps,
  compiled-builtins,
}:
let
  gradescope-base = dockerTools.pullImage {
    imageName = "gradescope/autograder-base";
    imageDigest = "sha256:786de5bb6f0825a9f0bbbc19c9733a386c9e2dc8a320ddf95a32a324b2f5db50";
    sha256 = "sha256-wvCsstrBpA95Vgja54fZT7BtCnLBx56IZkKFzn6irvw=";
    arch = "amd64";
  };

  runtime = runCommand "gradescope-runtime" { } ''
    set -euo pipefail

    NODE_MODULES="$out/node_modules"
    mkdir -p "$NODE_MODULES"
    cp -r ${runtime-deps}/node_modules/. "$NODE_MODULES"

    SHARE="$out/share/pyret-autograder"
    mkdir -p "$SHARE"
    cp -r ${compiled-builtins} "$SHARE/compiled"
  '';
in

dockerTools.streamLayeredImage {
  name = "pyret-autograder-gradescope-run";
  tag = "0.0.1-pre.1";

  fromImage = gradescope-base;

  contents = [
    nodejs-slim-stripped
    runtime
  ];
  config = {
  };
}
