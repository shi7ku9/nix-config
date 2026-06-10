{ ... }:

{
  flake.homeModules."user/shiziku" =
    { ... }:
    {
      xdg.configFile."kitty/" = {
        source = ./kitty;
        recursive = true;
      };
    };
}
