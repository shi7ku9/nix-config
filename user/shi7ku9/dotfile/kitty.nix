{ ... }:

{
  flake.homeModules."user/shi7ku9" =
    { ... }:
    {
      xdg.configFile."kitty/" = {
        source = ./kitty;
        recursive = true;
      };
    };
}
