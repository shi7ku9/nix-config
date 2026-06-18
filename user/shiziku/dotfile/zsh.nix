{ ... }:

{
  flake.homeModules."user/shiziku" =
    { ... }:
    {
      programs.zsh = {
        initContent = ''
          if [[ -f ~/api-keys/.env ]] then
            source ~/api-keys/.env
          fi
          if [[ -d ~/.npm-global/bin/ ]] then
            export PATH=$PATH:~/.npm-global/bin/:
          fi
        '';
      };
    };
}
