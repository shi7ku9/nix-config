{ ... }:

{
  flake.homeModules.nvf =
    { pkgs, ... }:
    {
      programs.nvf.settings.vim = {
        # — Plugin: autopairs —
        autopairs.nvim-autopairs = {
          enable = true;
        };

        # — Plugin: telescope —
        telescope.enable = true;

        # — Plugin: lualine (statusline) —
        statusline.lualine.enable = true;

        # — Plugin: bufferline (tabline) —
        tabline.nvimBufferline.enable = true;

        # — Plugin: nvim-tree (file tree) —
        filetree.nvimTree.enable = true;

        # — Plugin: gitsigns —
        git.gitsigns.enable = true;

        # — Plugin: which-key —
        binds.whichKey.enable = true;

        # — Plugin: nvim-notify —
        notify.nvim-notify.enable = true;

        # — Plugin: noice (UI) —
        ui.noice.enable = true;

        # — Plugin: conform (format on save) —
        formatter.conform-nvim = {
          enable = true;
          setupOpts = {
            format_on_save = {
              lsp_fallback = true;
              timeout_ms = 500;
            };
          };
        };

        # — Plugin: alpha (dashboard) —
        dashboard.alpha = {
          enable = true;
          theme = "startify";
        };

        # — Plugin: snacks —
        utility.snacks-nvim.enable = true;

        # — Plugin: nvim-web-devicons —
        visuals.nvim-web-devicons.enable = true;

        # — Plugin: blink.cmp (completion) —
        autocomplete.blink-cmp = {
          enable = true;
          setupOpts = {
            completion = {
              documentation = {
                auto_show = true;
              };
            };

            keymap = {
              preset = "super-tab";
            };
          };
        };
      };
    };
}
