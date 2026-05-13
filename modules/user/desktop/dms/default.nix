{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.desktop.dms;

  enbaledUser = lib.filterAttrs (_: userCfg: userCfg.enable) cfg.users;
in
{
  options.my.desktop.dms = {
    enable = lib.mkEnableOption "dms desktop";

    users = lib.mkOption {

      type = lib.types.attrsOf (

        lib.types.submodule (
          { name, ... }:
          {
            options = {
              enable = lib.mkEnableOption "Enable DMS for ${name}";
            };

          }
        )
      );

      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.hyprland.enable = true;

    programs.dms-shell = {
      enable = true;

      systemd = {
        enable = true;
      };
      enableAudioWavelength = true;
      enableSystemMonitoring = true;
    };

    environment.systemPackages = with pkgs; [
      kitty
      kdePackages.dolphin
    ];

    home-manager.users = lib.mapAttrs (name: _: import ./home-manager.nix) enbaledUser;
  };
}
# programs.hyprland.enable = true;
#   programs.dms-shell = {
#     enable = true;

#     systemd = {
#       enable = true;
#     };

#     enableAudioWavelength = true;
#     enableSystemMonitoring = true;

#     quickshell.package = pkgs.quickshell;
#   };
