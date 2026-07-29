{
  dockerTools,
  gradescope-build,
  bash,
  coreutils,
  file,
  nodejs-slim-stripped,
  runtime-make-wrapper,
}:
dockerTools.streamLayeredImage {
  name = "pyretautograder/gradescope-build";
  tag = "0.0.1-pre.2";

  contents = [
    gradescope-build
    bash
    coreutils
    file
    nodejs-slim-stripped
    runtime-make-wrapper
  ];
  config = {
  };
}
