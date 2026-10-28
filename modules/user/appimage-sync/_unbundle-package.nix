# Plain package function for appimage-unbundle, used by appimage-sync.nix.
# Not a flake-parts module: the leading `_` keeps import-tree from importing it.
{
  writeShellApplication,
  coreutils,
  findutils,
  squashfsTools,
}:

writeShellApplication {
  name = "appimage-unbundle";
  runtimeInputs = [
    coreutils
    findutils
    squashfsTools
  ];
  text = builtins.readFile ./appimage-unbundle.sh;
}
