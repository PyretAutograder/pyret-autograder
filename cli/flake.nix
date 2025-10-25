{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.05";
    systems.url = "github:nix-systems/default";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      systems,
      treefmt-nix,
      ...
    }:
    let
      eachSystem = f: nixpkgs.lib.genAttrs (import systems) (s: f (import nixpkgs { system = s; }));
      treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./nix/treefmt.nix);
    in
    {
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);

      devShells = eachSystem (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            nodejs_24
            gnumake
            coreutils-full
          ];
          shellHook = ''
            export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [ pkgs.libuuid ]}:''$LD_LIBRARY_PATH"
          '';
        };
      });
    };
}
