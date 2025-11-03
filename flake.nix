{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      systems,
      treefmt-nix,
    }:
    let
      inherit (nixpkgs) lib legacyPackages;
      eachSystem = f: lib.genAttrs (import systems) (system: f legacyPackages.${system});
      treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./nix/treefmt.nix);
    in
    {
      packages = eachSystem (pkgs: import ./nix/packages/default.nix { inherit pkgs; });

      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);

      apps = eachSystem (
        pkgs:
        let
          packages = self.packages.${pkgs.system};
        in
        {
          default = {
            type = "app";
            program = "${packages.cli}/bin/cli";
          };
          pawtograder-pyret = {
            type = "app";
            program = "${packages.pawtograder-exec}/bin/pyret-pawtograder";
          };
        }
      );

      checks = eachSystem (pkgs: {

      });

      devShells = eachSystem (pkgs: {
        default = pkgs.mkShell {
          packages =
            (with pkgs; [
              git
              gnumake
            ])
            ++ (with self.packages.${pkgs.system}; [
              nodejs
              pnpm
            ]);
          shellHook = ''
            export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [ pkgs.libuuid ]}:''$LD_LIBRARY_PATH"
          '';
        };
      });
    };
}
