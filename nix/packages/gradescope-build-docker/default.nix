{
  dockerTools,
  gradescope-build,
  gradescope-version,
  bash,
  coreutils,
  file,
  nodejs-slim-stripped,
  runtime-make-wrapper,
}:
dockerTools.streamLayeredImage {
  name = "pyretautograder/gradescope-build";
  tag = gradescope-version;

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
