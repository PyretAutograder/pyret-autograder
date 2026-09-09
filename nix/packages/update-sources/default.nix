{
  writeShellApplication,
  curl,
  jq,
  moreutils,
  nix,
  prefetch-npm-deps,
}:

writeShellApplication {
  name = "update-sources";
  runtimeInputs = [
    curl
    jq
    moreutils
    nix
    prefetch-npm-deps
  ];
  text = builtins.readFile ./update-sources.sh;
}
