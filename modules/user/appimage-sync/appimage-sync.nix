{ ... }:

{
  flake.homeModules.appimage-sync =
    { pkgs, ... }:
    {
      # Syncing executes AppImage extraction runtimes, so expose only a manual CLI.
      home.packages = [ (pkgs.callPackage ./_package.nix { }) ];
    };
}
