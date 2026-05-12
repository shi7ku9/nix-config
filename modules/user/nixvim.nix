{inputs, ...}:

{
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];
  programs.nixvim = {
    enable = true;

    colorschemes.catppuccin = {
      enable = true;
      settings = {
        flavour = "frappe";
      };
    };
    globals.mapleader = " ";

    plugins = {

      lightline.enable = true;
      telescope.enable = true;
      treesitter.enable = true;
      web-devicons.enable = true;
      mini-pairs.enable = true;
      which-key = {
        enable = true;
        autoLoad = true;
      };
      conform-nvim.enable = true;
      lint.enable = true;
      bufferline.enable = true;
      snacks.enable = true;
      blink-cmp.enable = true;
    };
    lsp = {
      enable = true;
      servers = {
        nixd.enable = true; # Nix
      };
    };
  };
}
