{ ... }:

{
  flake.homeModules.nixvim =
    { config, pkgs, ... }:
    {
      programs.nixvim = {

        plugins = {
          lspconfig.enable = true;
          blink-cmp = {
            enable = true;
            settings = {
              completion = {
                accept.auto_brackets.enabled = true;
                documentation.auto_show = true;
              };
              keymap = {
                preset = "super-tab";
              };
            };
          };
          conform-nvim = {
            enable = true;

            settings.format_on_save = ''
              function(bufnr)
                if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                  return
                end

                return { timeout_ms = 200, lsp_fallback = true }, on_format
               end
            '';
          };
          treesitter = {
            enable = true;
            highlight.enable = true;
            indent.enable = true;
            grammarPackages = with config.programs.nixvim.plugins.treesitter.package.builtGrammars; [
              bash
              lua
              make
              markdown
              nix
              toml
              yaml
              zig
              cpp
              c
              go
            ];
          };

          trouble.enable = true;
        };

        lsp = {
          enable = true;
          servers = {
            clangd.enable = true;
            gopls.enable = true;
            zls.enable = true;
          };
          keymaps = [
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
      home.packages = with pkgs; [
        tree-sitter
      ];
    };
}
