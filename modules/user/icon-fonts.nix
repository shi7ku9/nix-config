{pkgs, ...}:

{
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # theme
    bibata-cursors
    hicolor-icon-theme
    kdePackages.breeze-icons
    
    # think as fonts.package
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
  ];
}