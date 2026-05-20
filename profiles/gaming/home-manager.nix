{ ... }:

{
  flake.homeModules.profiles-gaming =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
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
        easyeffects
      ];
    };
}
