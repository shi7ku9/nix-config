{ ... }:

{
  flake.homeModules.editor =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [ vim ];

      home.sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };
    };
}
