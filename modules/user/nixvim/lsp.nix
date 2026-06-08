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
                return { timeout_ms = 200, lsp_fallback = true }
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
            nixd.enable = true;
            # Additional LSP servers common in LazyVim (meson excluded)
            rust_analyzer.enable = true;
            pyright.enable = true;
            ts_ls.enable = true;
            html.enable = true;
            cssls.enable = true;
            jsonls.enable = true;
            yamlls.enable = true;
          };
        };
      };
      home.packages = with pkgs; [
        tree-sitter
      ];
    };
}
