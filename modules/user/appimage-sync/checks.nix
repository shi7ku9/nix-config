# Flake check: `nix flake check` / `nix build .#checks.x86_64-linux.appimage-sync`
# runs _test.sh against the real packaged script.
{ ... }:

{
  perSystem =
    { pkgs, ... }:
    {
      checks.appimage-sync = pkgs.callPackage ./_check.nix {
        appimage-sync = pkgs.callPackage ./_package.nix { };
      };
    };
}
