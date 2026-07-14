{ ... }:

{
  flake.homeModules."user/shiziku" =
    { ... }:
    {
      xdg = {
        mime.enable = true;

        mimeApps = {
          enable = true;
          defaultApplications = {
            "text/html" = [ "zen-browser.desktop" ];
            "x-scheme-handler/http" = [ "zen-browser.desktop" ];
            "x-scheme-handler/https" = [ "zen-browser.desktop" ];
          };
        };
      };

      xdg.dataFile."kio/servicemenus/open-at-kitty.desktop".text = ''
        [Desktop Entry]
        Type=Service
        ServiceTypes=KonqPopupMenu/Plugin
        MimeType=inode/directory;
        Actions=openAtKitty;
        X-KDE-Priority=TopLevel

        [Desktop Action openAtKitty]
        Name=Open in Kitty
        Icon=kitty
        Exec=kitty --directory %f
      '';
    };
}
