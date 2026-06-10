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
        '';
      };
    };
}
