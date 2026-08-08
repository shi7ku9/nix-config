{ ... }:

{
  flake.homeModules."user/shi7ku9" =
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
