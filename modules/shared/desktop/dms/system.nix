{ ... }:
{
  flake.nixosModules."desktop/dms" =
    { pkgs, ... }:
    {

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
