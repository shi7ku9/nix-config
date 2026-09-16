{ ... }:

{
  flake.homeModules.icon-fonts =
    { pkgs, ... }:
    {
      fonts.fontconfig = {
        enable = true;
        antialiasing = true;
        defaultFonts = {
          emoji = [ "Noto Color Emoji" ];
          monospace = [
            "JetBrains Mono"
            "Fira Code"
            "DejaVu Sans Mono"
            "Noto Sans Mono"
          ];
          sansSerif = [
            "DejaVu Sans"
            "Noto Sans"
            "Sarasa Gothic TC"
            "Noto Sans CJK TC"
          ];
          serif = [
            "DejaVu Serif"
            "Noto Serif"
            "Noto Serif CJK TC"
          ];
        };
      };

      home.packages = with pkgs; [
        # theme
        bibata-cursors
        hicolor-icon-theme
        kdePackages.breeze-icons

        # think as fonts.package
        dejavu_fonts
        fira-code
        jetbrains-mono
        nerd-fonts.symbols-only
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-color-emoji
        sarasa-gothic
      ];
    };
}
