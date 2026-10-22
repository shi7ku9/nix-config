# Plain package function shared by the Home Manager module (appimage-sync.nix)
# and the flake check (checks.nix). Not a flake-parts module: the leading `_`
# keeps import-tree from importing it.
{
  writeShellApplication,
  coreutils,
  findutils,
  gawk,
  file,
  desktop-file-utils,
}:

writeShellApplication {
  name = "appimage-sync";
  runtimeInputs = [
    coreutils
    findutils
    gawk
    file
    desktop-file-utils
  ];
  # No errexit: a failed icon extraction must not abort the whole sync.
  bashOptions = [
    "nounset"
    "pipefail"
  ];
  text = builtins.readFile ./appimage-sync.sh;
}
