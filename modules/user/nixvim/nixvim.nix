{ inputs, ... }:

{
  flake.homeModules.nixvim =
    { ... }:
    {
      imports = [
        inputs.nixvim.homeModules.nixvim
      ];

      programs.nixvim = {
        enable = true;
        nixpkgs.source = inputs.nixpkgs;
        opts = {
          tabstop = 2;
          shiftwidth = 2;
          expandtab = true;
          smartindent = true;
          number = true;
          relativenumber = true;
        };
        colorschemes.catppuccin = {
          enable = true;
          settings.flavour = "frappe";
        };
      };

    };

}
