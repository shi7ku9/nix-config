{ ... }:

{
  flake.homeModules.editor =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [ vim ];

      home.sessionVariables = {
        EDITOR = "vim";
        VISUAL = "vim";
      };
    };
}
