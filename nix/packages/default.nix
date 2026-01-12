{ pkgs }:
let
  callPackage = pkgs.lib.callPackageWith (pkgs // fakePackages // packages);
  fakePackages = {
    inherit callPackage;
    buildNpmPackageCanvas = callPackage ./build-npm-package-canvas { };
  };
  packages = {
    nodejs = pkgs.nodejs_24;
    pnpm = pkgs.pnpm_10;
    nodejs-slim-stripped = callPackage ./nodejs-slim-stripped { };
    pyret-lang-src = callPackage ./pyret-lang-src { };
    pyret-lang = callPackage ./pyret-lang { };
    pyret-npm = callPackage ./pyret-npm { };
    cpo-src = callPackage ./cpo-src { };
    compiled-builtins = callPackage ./compiled-builtins { };
    runtime-deps = callPackage ./runtime-deps { };
    pyret-autograder-src = callPackage ./pyret-autograder-src { };
    pyret-autograder-prepared = callPackage ./pyret-autograder-prepared { };
    pawtograder-exec = callPackage ./pawtograder-exec { };
    # pawtograder-docker = callPackage ./pawtograder-docker { };
    cli = callPackage ./cli { };
    gradescope-build = callPackage ./gradescope-build { };
    gradescope-build-docker = callPackage ./gradescope-build-docker { };
    gradescope-run-docker = callPackage ./gradescope-run-docker { };
    runtime-make-wrapper = callPackage ./runtime-make-wrapper {};

    scc = callPackage ./scc { };
  };
in
packages
