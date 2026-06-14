# noctalia-shell desktop profile
{ ... }:

{
  flake.nixosModules."desktop/noctalia-shell" =
    { pkgs, ... }:
    {
      programs.hyprland.enable = true;

      environment.systemPackages = with pkgs; [
        noctalia-shell
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
