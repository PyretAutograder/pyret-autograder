{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs =
    {
      self,
      nixpkgs,
      systems,
    }:
    let
      eachSystem = f: nixpkgs.lib.genAttrs (import systems) (s: f (import nixpkgs { system = s; }));
    in
    {
      packages = eachSystem (pkgs: {
        default = pkgs.buildFHSEnv {
          name = "pyret-fhs-env";

          targetPkgs =
            pkgs: with pkgs; [
              nodejs_22
              git
              gnumake
              bash
              curl
              python3
            ];

          runScript = "bash";
        };
      });

      devShells = eachSystem (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            nodejs_22
            gnumake
          ];
        };
      });
    };
}
