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

        # F13 does nothing: kitty's CSI u encoding, and the terminfo (xterm) one.
        initContent = ''
          noop-widget() { :; }
          zle -N noop-widget
          bindkey '\e[57376u' noop-widget
          bindkey '\e[1;2P' noop-widget
        '';
      };

      programs.eza = {
        enable = true;
        # Aliases are defined explicitly below so every one carries --color=auto.
        enableZshIntegration = false;
      };

      programs.zsh.shellAliases = {
        ls = "eza --color=auto";
        l = "eza -l --color=auto";
        ll = "eza -lah --color=auto --git";
        la = "eza -a --color=auto";
        lt = "eza --tree --level=2 --color=auto";
      };

      # Ctrl-R history, Ctrl-T files, Alt-C cd.
      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
      };

      programs.starship = {
        enable = true;
        enableZshIntegration = true;
      };

      home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];
    };
}
