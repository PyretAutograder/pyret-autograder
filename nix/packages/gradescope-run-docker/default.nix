{
  dockerTools,
  lib,
  runtime-deps,
  nodejs-slim-stripped,
}:
let
  gradescope-base = dockerTools.pullImage {
    imageName = "gradescope/autograder-base";
    imageDigest = "sha256:786de5bb6f0825a9f0bbbc19c9733a386c9e2dc8a320ddf95a32a324b2f5db50";
    sha256 = lib.fakeHash;
    arch = "amd64";
  };

in

dockerTools.streamLayeredImage {
  name = "pyret-autograder-gradescope-run";
  tag = "0.0.1-pre.1";

  fromImage = gradescope-base;

  contents = [
    runtime-deps
    nodejs-slim-stripped
  ];
  config = {
  };
}
