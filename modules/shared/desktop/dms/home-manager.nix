{ ... }:

{
  flake.homeModules."desktop/dms" =
    { ... }:
    {
      xdg.configFile."hypr/hyprland.lua".source = ./hypr/hyprland.lua;
    };
}
