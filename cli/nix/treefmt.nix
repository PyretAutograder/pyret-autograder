{ ... }:
{
  projectRootFile = "flake.nix";
  settings.global.excludes = [
    "COPYING"
    ".envrc"
    "**/.gitignore"
  ];
  programs = {
    deadnix.enable = true;
    nixfmt.enable = true;
    mdformat.enable = true;
    prettier.enable = true;
  };
  settings.formatter = {
    prettier.options = [
      "--config"
      (toString ../.prettierrc.json)
    ];
  };
}
