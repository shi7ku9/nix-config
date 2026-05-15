{ ... }:

{
  flake.homeModules.user-shiziku-default-applications =
    { ... }:
    {
      xdg = {
        mime.enable = true;

        mimeApps = {
          enable = true;
          defaultApplications = {
            "text/html" = [ "firefox.desktop" ];
            "x-scheme-handler/http" = [ "firefox.desktop" ];
            "x-scheme-handler/https" = [ "firefox.desktop" ];
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
