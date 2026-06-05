{ ... }:

{
  flake.homeModules.nixvim =
    { ... }:
    {
      programs.nixvim = {
        globals.mapleader = " ";
        keymaps = [
          {
            action = "<Esc>";
            key = "jj"; # jia jia jia
            mode = [ "i" ];
          }
          {
            action = "<Esc>";
            key = "<f13>";
            mode = [
              "i"
              "n"
              "v"
              "c"
            ];
          }
          {
            action = "<Cmd>NvimTreeOpen<Enter>";
            key = "<leader>o";
            mode = [ "n" ];
            options.desc = "Open NvimTree";
          }
          {
            action = "<Cmd>NvimTreeToggle<Enter>";
            key = "<leader>e";
            mode = [ "n" ];
            options.desc = "Toggle NvimTree";
          }
          {
            action = "<Cmd>Trouble diagnostics toggle focus=true<Enter>";
            key = "<leader>ld";
            mode = [ "n" ];
            options.desc = "Diagnostics";
          }

        ];
        plugins = {
          which-key.enable = true;
          telescope.keymaps = {
            "<leader>fg" = {
              action = "live_grep";
              options.desc = "Live Grep";
            };
            "<leader>ff" = {
              action = "find_files";
              options.desc = "Find Files";
            };
            "<leader>fb" = {
              action = "buffers";
              options.desc = "Buffers";
            };
          };
          settings.defaults = {
            mappings = {
              i."<f13>" = {
                action = "";
                __raw = "require('telescope.actions').close";
              };
              n."<f13>" = {
                __raw = "require('telescope.actions').close";
              };
            };
          };
        };
        lsp.keymaps = [
          {
            key = "gd";
            lspBufAction = "definition";
            options.desc = "Definition";
          }
          {
            key = "gD";
            lspBufAction = "references";
            options.desc = "References";
          }
          {
            key = "gt";
            lspBufAction = "type_definition";
            options.desc = "Type Definition";
          }
          {
            key = "gi";
            lspBufAction = "implementation";
            options.desc = "Implementation";
          }
          {
            key = "K";
            lspBufAction = "hover";
            options.desc = "Hover";
          }
          {
            key = "<leader>la";
            lspBufAction = "code_action";
            options.desc = "LSP Action";
          }
          {
            key = "<leader>lr";
            lspBufAction = "rename";
            options.desc = "Rename Symbols";
          }
        ];
      };
    };
}
