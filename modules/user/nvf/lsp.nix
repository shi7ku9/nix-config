{ ... }:

{
  flake.homeModules.nvf = { pkgs, ... }: {
    programs.nvf.settings.vim = {
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
    };
  };
}
