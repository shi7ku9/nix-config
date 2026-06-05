{ ... }:

{

  flake.homeModules.nixvim =
    { ... }:
    {
      programs.nixvim = {
        plugins = {
          #lazy.enable = true; I'm Lazy to config Lazy. lol
          snacks.enable = true;
          noice.enable = true;
          web-devicons.enable = true;
          nvim-tree.enable = true;
          telescope.enable = true;
        };

      };

    };
}
