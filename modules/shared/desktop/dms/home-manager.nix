{ ... }:

{
  flake.homeModules.desktop-dms =
    { ... }:
    {
      xdg.configFile."hypr".source = ./hypr;
    };
}
