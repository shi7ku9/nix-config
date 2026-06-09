{ pkgs, ... }:

{
  flake.homeModules.neovim = {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      withPython3 = true;

      initLua = builtins.readFile ./config/init.lua;
    };

    xdg.configFile = {
      "nvim/lua/options.lua".source = ./config/options.lua;
      "nvim/lua/keymaps.lua".source = ./config/keymaps.lua;
      "nvim/lua/plugins/catppuccin.lua".source = ./config/plugins/catppuccin.lua;
      "nvim/lua/plugins/telescope.lua".source = ./config/plugins/telescope.lua;
      "nvim/lua/plugins/lualine.lua".source = ./config/plugins/lualine.lua;
      "nvim/lua/plugins/bufferline.lua".source = ./config/plugins/bufferline.lua;
      "nvim/lua/plugins/nvim-tree.lua".source = ./config/plugins/nvim-tree.lua;
      "nvim/lua/plugins/alpha.lua".source = ./config/plugins/alpha.lua;
      "nvim/lua/plugins/gitsigns.lua".source = ./config/plugins/gitsigns.lua;
      "nvim/lua/plugins/noice.lua".source = ./config/plugins/noice.lua;
      "nvim/lua/plugins/notify.lua".source = ./config/plugins/notify.lua;
      "nvim/lua/plugins/nvim-autopairs.lua".source = ./config/plugins/nvim-autopairs.lua;
      "nvim/lua/plugins/snacks.lua".source = ./config/plugins/snacks.lua;
      "nvim/lua/plugins/trouble.lua".source = ./config/plugins/trouble.lua;
      "nvim/lua/plugins/web-devicons.lua".source = ./config/plugins/web-devicons.lua;
      "nvim/lua/plugins/which-key.lua".source = ./config/plugins/which-key.lua;
      "nvim/lua/plugins/conform.lua".source = ./config/plugins/conform.lua;
      "nvim/lua/plugins/blink-cmp.lua".source = ./config/plugins/blink-cmp.lua;
      "nvim/lua/plugins/treesitter.lua".source = ./config/plugins/treesitter.lua;
      "nvim/lua/plugins/lsp.lua".source = ./config/plugins/lsp.lua;
    };
  };
}
