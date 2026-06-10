{ ... }:

{
  flake.homeModules.nvf = { pkgs, ... }: {
    programs.nvf.settings.vim = {
      # — Keymaps (mirrors the original keymaps.lua) —
      keymaps = [
        # leader
        {
          mode = "n";
          key = "<Space>";
          action = "<Nop>";
        }

        # insert mode escape
        {
          mode = "i";
          key = "jj";
          action = "<Esc>";
          desc = "Exit insert mode";
        }
        {
          mode = [
            "i"
            "n"
            "v"
            "c"
          ];
          key = "<f13>";
          action = "<Esc>";
          desc = "Escape via F13";
        }

        # file ops
        {
          mode = "n";
          key = "<leader>w";
          action = ":w<CR>";
          desc = "Save file";
        }
        {
          mode = "n";
          key = "<leader>q";
          action = ":q<CR>";
          desc = "Quit";
        }
        {
          mode = "n";
          key = "<leader>Q";
          action = ":xa<CR>";
          desc = "Quit all";
        }

        # window navigation
        {
          mode = "n";
          key = "<C-h>";
          action = "<C-w>h";
          desc = "Window left";
        }
        {
          mode = "n";
          key = "<C-j>";
          action = "<C-w>j";
          desc = "Window down";
        }
        {
          mode = "n";
          key = "<C-k>";
          action = "<C-w>k";
          desc = "Window up";
        }
        {
          mode = "n";
          key = "<C-l>";
          action = "<C-w>l";
          desc = "Window right";
        }
        {
          mode = "n";
          key = "<leader>=";
          action = "<C-w>=";
          desc = "Equalize windows";
        }

        # telescope (also registered by telescope plugin config)
        {
          mode = "n";
          key = "<leader>fg";
          action = "<Cmd>Telescope live_grep<CR>";
          desc = "Live Grep";
        }
        {
          mode = "n";
          key = "<leader>ff";
          action = "<Cmd>Telescope find_files<CR>";
          desc = "Find Files";
        }
        {
          mode = "n";
          key = "<leader>fb";
          action = "<Cmd>Telescope buffers<CR>";
          desc = "Buffers";
        }

        # nvim-tree
        {
          mode = "n";
          key = "<leader>o";
          action = "<Cmd>NvimTreeOpen<CR>";
          desc = "Open NvimTree";
        }
        {
          mode = "n";
          key = "<leader>e";
          action = "<Cmd>NvimTreeToggle<CR>";
          desc = "Toggle NvimTree";
        }

        # trouble
        {
          mode = "n";
          key = "<leader>ld";
          action = "<Cmd>Trouble diagnostics toggle focus=true<CR>";
          desc = "Diagnostics";
        }
      ];
    };
  };
}
