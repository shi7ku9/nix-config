{ ... }:

{
  flake.homeModules."desktop/noctalia-shell" =
    { inputs, ... }:
    {
      xdg.configFile."hypr/hyprland.lua".source = ./hypr/hyprland.lua;
    };
}
