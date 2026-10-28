# Flake checks: `nix flake check` / `nix build .#checks.x86_64-linux.<name>`
# run _test.sh / _unbundle-test.sh against the real packaged scripts.
{ ... }:

{
  perSystem =
    { pkgs, ... }:
    {
      checks.appimage-sync = pkgs.callPackage ./_check.nix {
        appimage-sync = pkgs.callPackage ./_package.nix { };
      };
      checks.appimage-unbundle = pkgs.callPackage ./_unbundle-check.nix {
        appimage-unbundle = pkgs.callPackage ./_unbundle-package.nix { };
      };
    };
}
