{ ... }:

{
  flake.homeModules.profiles-gaming =
    { pkgs, ... }:
    {
      nixpkgs.overlays = [
        # Skipping tests while upstream sorts it out, revert once
        # Hydra consistently builds openldap green.
        (final: prev: {
          openldap = prev.openldap.overrideAttrs (_: {
            doCheck = false;
          });
        })
      ];
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
        lutris-free

        # idk
        easyeffects # denoise
      ];
    };
}
