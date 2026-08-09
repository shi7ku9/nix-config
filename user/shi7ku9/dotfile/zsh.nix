{ ... }:

{
  flake.homeModules."user/shi7ku9" =
    { ... }:
    {
      programs.zsh = {
        shellAliases = {
          sandbox = ''
            bwrap --die-with-parent --ro-bind / / --dev /dev --proc /proc --ro-bind /sys /sys --bind "$PWD" "$PWD" --tmpfs /tmp --chdir "$PWD" --setenv HISTFILE /tmp/.sandbox.zsh_history --setenv SANDBOX 1 zsh
          '';
        };
        initContent = ''
          if [[ -f ~/api-keys/.env ]] then
            source ~/api-keys/.env
          fi
        '';
      };
    };
}
