{ inputs, ... }:

{
  flake.homeModules.nvf =
    { pkgs, ... }:
    {
      imports = [ inputs.nvf.homeManagerModules.default ];

      programs.nvf = {
        enable = true;
        defaultEditor = true;

        settings = {
          vim = {
            # — Vim options —
            options = {
              tabstop = 2;
              shiftwidth = 2;
              expandtab = true;
              smartindent = true;
              mouse = "a";
              clipboard = "unnamedplus";
            };
            lineNumberMode = "relNumber";

            # — Theme: catppuccin frappe —
            theme = {
              enable = true;
              name = "catppuccin";
              style = "frappe";
            };

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

            # — LSP (mappings use vim.lsp.mappings below) —
            lsp = {
              enable = true;
              formatOnSave = false;

              mappings = {
                goToDefinition = "gd";
                listReferences = "gD";
                goToType = "gt";
                listImplementations = "gi";
                hover = "K";
                codeAction = "<leader>la";
                renameSymbol = "<leader>lr";
              };

              # trouble is a lsp submodule
              trouble.enable = true;
            };

            # — Language support (LSP + treesitter + grammars) —
            languages = {
              enableTreesitter = true;
              enableFormat = false;

              nix.enable = true;
              lua.enable = true;
              python.enable = true;
              rust.enable = true;
              typescript.enable = true;
              html.enable = true;
              css.enable = true;
              json.enable = true;
              yaml.enable = true;
              go.enable = true;
              zig.enable = true;
              clang.enable = true;
              bash.enable = true;
              markdown.enable = true;
            };

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
      };
    };
}
