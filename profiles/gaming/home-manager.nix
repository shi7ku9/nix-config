{pkgs, ...}:

{
  home.packages = with pkgs; [
    # minecraft !
    prismlauncher

    # discord
    vesktop

    # wine 
    wineWow64Packages.stableFull
    winetricks

    # idk 
  ];
}