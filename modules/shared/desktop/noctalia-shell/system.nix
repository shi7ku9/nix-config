# noctalia-shell desktop profile
{ inputs, ... }:

{
  flake.nixosModules."desktop/noctalia-shell" =
    { pkgs, ... }:
    {
      imports = [
        inputs.noctalia.nixosModules.default
      ];

      programs.hyprland.enable = true;

      programs.noctalia = {
        enable = true;

        # Enables NetworkManager, Bluetooth, UPower, and a power profile service.
        recommendedServices.enable = true;
      };

      environment.systemPackages = with pkgs; [
        kitty
        kdePackages.dolphin
        playerctl
        grim
        slurp
        wl-clipboard
        jq
      ];
    };
}
