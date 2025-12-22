{
  dockerTools,
  gradescope-build,
  bash,
  coreutils,
  file,
  nodejs-slim-stripped,
  makeWrapper,
}:
dockerTools.streamLayeredImage {
  name = "pyret-autograder-gradescope-build";
  tag = "0.0.1-pre.1";

  contents = [
    gradescope-build
    bash
    coreutils
    file
    nodejs-slim-stripped
    makeWrapper
  ];
  config = {
  };
}
