{
  writeShellApplication,
  makeWrapper,
  dieHook,
}:
writeShellApplication {
  name = "makeWrapper";
  runtimeInputs = [
    dieHook
    makeWrapper
  ];
  excludeShellChecks = [ "SC1091" ]; # don't check inputs
  text = ''
    set -euo pipefail
    source ${dieHook}/nix-support/setup-hook
    source ${makeWrapper}/nix-support/setup-hook

    makeWrapper "$@"
  '';
}
