{ ... }:

{
  flake.homeModules.nvf =
    { pkgs, ... }:
    {
      programs.nvf.settings.vim = {
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
      };
    };
}
