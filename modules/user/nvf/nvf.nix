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
            # — Theme: catppuccin frappe —
            theme = {
              enable = true;
              name = "catppuccin";
              style = "frappe";
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
          };
        };
      };
    };
}
