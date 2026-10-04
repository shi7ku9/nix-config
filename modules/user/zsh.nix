{ ... }:

{
  flake.homeModules.zsh =
    { config, ... }:
    {
      programs.zsh = {
        enable = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        history = {
          size = 50000;
          save = 50000;
          ignoreAllDups = true;
          share = true;
        };
      };

      programs.starship = {
        enable = true;
        enableZshIntegration = true;
      };

      home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];
    };
}
