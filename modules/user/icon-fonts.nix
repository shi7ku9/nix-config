{ pkgs, ... }:

{
  fonts.fontconfig = {
    enable = true;
    antialiasing = true;
  };

  home.packages = with pkgs; [
    # theme
    bibata-cursors
    hicolor-icon-theme
    kdePackages.breeze-icons

    # think as fonts.package
    nerd-fonts.symbols-only
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    sarasa-gothic
  ];
}
