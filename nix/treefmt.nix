{ ... }:
{
  projectRootFile = "flake.nix";
  settings.global.excludes = [
    "COPYING"
    "COPYING.LESSER"
    ".envrc"
    "**/.gitignore"
  ];
  programs = {
    nixfmt.enable = true;
    # mdformat.enable = true;
    # prettier.enable = true;
  };
  settings.formatter = {
    # prettier.options = [
    #   "--config"
    #   (toString ../.prettierrc.json)
    # ];
  };
}
