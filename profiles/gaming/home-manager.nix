{pkgs, ...}:

{
  home.packages = with pkgs; [
    # minecraft !
    prismlauncher

    # discord
    vesktop

    # wine 
    wineWow64Packages.stable
    winetricks

    # idk 
  ];
}