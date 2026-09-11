{ ... }:

{
  flake.homeModules.zsh =
    { pkgs, ... }:
    {
      home.sessionPath = [ "$HOME/.local/bin" ];

      programs.starship = {
        enable = true;

        presets = [ "plain-text-symbols" ];

        settings.custom.sandbox = {
          when = ''[ -n "$SANDBOX" ]'';
          command = "true";
          format = "via [sandbox](bold red)";
        };
      };
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        shellAliases = {
          ll = "eza --icons auto -l";
        };
        history.size = 100000;
        history.save = 50000;

        history.ignorePatterns = [
          "rm *"
          "pkill *"
          "cp *"
        ];

        plugins = [
          {
            name = "zsh-syntax-highlighting";
            src = pkgs.zsh-syntax-highlighting;
          }
          {
            name = "zsh-autosuggestions";
            src = pkgs.zsh-autosuggestions;
          }
          {
            name = "zsh-fzf-tab";
            src = pkgs.zsh-fzf-tab;
          }
        ];

        initContent = ''
          bindkey -e
          bindkey  "\e[57376u" end-of-line
        '';
      };
    };
}
