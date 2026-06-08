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
          # LazyVim‑inspired additions
          lualine = {
            enable = true;
          };
          bufferline = {
            enable = true;
          };
          nvim-autopairs.enable = true;
          nvim-ts-context-commentstring.enable = true;
          gitsigns.enable = true;
          indent-blankline.enable = true;
          alpha.enable = true;
          nvim-colorizer.enable = true;
          notify.enable = true;
          vim-surround.enable = true;
        };

      };

    };
}
