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

        colorschemes.catppuccin.enable = true;
        puglins = {
          lualie.enable = true;
        };
      };

    };

}
