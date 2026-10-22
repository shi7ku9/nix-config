{ ... }:

{
  flake.homeModules.appimage-sync =
    { config, pkgs, ... }:
    let
      appimageDir = "${config.home.homeDirectory}/Appimage";

      appimage-sync = pkgs.callPackage ./_package.nix { };
    in
    {
      home.packages = [ appimage-sync ];

      # Keep launcher entries in sync with ~/Appimage, including deletions.
      systemd.user.paths.appimage-sync = {
        Unit.Description = "Watch ~/Appimage for AppImage changes";
        Path = {
          PathChanged = appimageDir;
          Unit = "appimage-sync.service";
        };
        Install.WantedBy = [ "default.target" ];
      };

      # Poll once a minute after each run for changes to external symlink
      # targets and to catch up after a run reaches its timeout.
      systemd.user.timers.appimage-sync = {
        Unit.Description = "Periodically sync AppImage desktop entries";
        Timer = {
          OnActiveSec = "1min";
          OnUnitInactiveSec = "1min";
          AccuracySec = "1s";
          Unit = "appimage-sync.service";
        };
        Install.WantedBy = [ "timers.target" ];
      };

      systemd.user.services.appimage-sync = {
        Unit.Description = "Sync ~/Appimage AppImages to desktop entries";
        Service = {
          Type = "oneshot";
          # Oneshot has no start timeout by default; a stuck run would keep
          # the path watch disabled.
          TimeoutStartSec = "15min";
          Environment = [ "APPIMAGE_DIR=${appimageDir}" ];
          # Short debounce so bursts of file events (downloads, copies) settle first
          ExecStartPre = "${pkgs.coreutils}/bin/sleep 2";
          ExecStart = "${appimage-sync}/bin/appimage-sync";
        };
        Install.WantedBy = [ "default.target" ];
      };
    };
}
