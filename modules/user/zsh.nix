{pkgs, ...}:

{
  programs.git.enable = true; # zplug required git
  programs.starship = {
    enable = true;

    presets = ["plain-text-symbols"];
  };
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;


    shellAliases = {
      ll = "exa -l";
    };
    history.size = 1000;

    history.ignorePatterns = ["rm *" "pkill *" "cp *"];

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
    

    # initContent = ''
    #   eval "$(starship init zsh)"
    # '';

  };
}
