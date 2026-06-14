{ ... }:

{
  flake.homeModules."desktop/noctalia-shell" =
    { ... }:
    {
      xdg.configFile."hypr/hyprland.lua".source = ./hypr/hyprland.lua;
    };
}
