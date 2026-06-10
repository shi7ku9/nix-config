{ ... }:

{
  flake.homeModules.profiles-gaming =
    { pkgs, pkgs-stable, ... }:
    {
      home.packages =
        (with pkgs; [
          # minecraft !
          prismlauncher

          # osu
          osu-lazer-bin

          # discord
          vesktop

          # wine
          wineWow64Packages.stableFull
          winetricks

          # idk
          easyeffects # denoise
          bubblewrap
        ])
        ++ (with pkgs-stable; [
          lutris-free
        ]);
    };
}
