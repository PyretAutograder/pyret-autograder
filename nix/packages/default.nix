{ pkgs }:
let
  callPackage = pkgs.lib.callPackageWith (pkgs // packages);
  packages = {
    inherit callPackage;
    nodejs = pkgs.nodejs_24;
    pnpm = pkgs.pnpm_10;
    nodejs-slim-stripped = callPackage ./nodejs-slim-stripped/default.nix { };
    buildNpmPackageCanvas = callPackage ./build-npm-package-canvas/default.nix { };
    pyret-lang-src = callPackage ./pyret-lang-src/default.nix { };
    pyret-lang = callPackage ./pyret-lang/default.nix { };
    pyret-npm = callPackage ./pyret-npm/default.nix { };
    cpo-src = callPackage ./cpo-src/default.nix { };
    compiled-builtins = callPackage ./compiled-builtins/default.nix { };
    runtime-deps = callPackage ./runtime-deps/default.nix { };
    pyret-autograder-src = callPackage ./pyret-autograder-src/default.nix { };
    pyret-autograder-prepared = callPackage ./pyret-autograder-prepared/default.nix { };
    pawtograder-exec = callPackage ./pawtograder-exec/default.nix { };
    scc = callPackage ./scc/default.nix { };
    cli = callPackage ./cli/default.nix { };
  };
in
packages
