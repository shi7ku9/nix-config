{ ... }:

{
  flake.homeModules."user/shi7ku9" =
    { ... }:
    {
      programs.zsh = {
        shellAliases = {
          sandbox = ''
            bwrap --die-with-parent --ro-bind / / --dev /dev --proc /proc --ro-bind /sys /sys --bind-try "$HOME/.cache" "$HOME/.cache" --bind "$PWD" "$PWD" --tmpfs /tmp --chdir "$PWD" --setenv HISTFILE /tmp/.sandbox.zsh_history --setenv SANDBOX 1 zsh
          '';
        };
        initContent = ''
          if [[ -f ~/.serect/.env ]] then
            source ~/.serect/.env
          fi

          omp-run() {
            (( $+commands[nono] )) || { print -u2 "missing: nono"; return 127; }
            (( $+commands[omp] )) || { print -u2 "missing: omp"; return 127; }
            command nono run --profile nolabs-ai/omp --allow /tmp -- omp "$@"
          }

          claude-run() {
            (( $+commands[nono] )) || { print -u2 "missing: nono"; return 127; }
            (( $+commands[claude] )) || { print -u2 "missing: claude"; return 127; }
            command nono run --profile nolabs-ai/claude --allow /tmp -- claude --dangerously-skip-permissions "$@"
          }

          opencode-run() {
            (( $+commands[nono] )) || { print -u2 "missing: nono"; return 127; }
            (( $+commands[opencode] )) || { print -u2 "missing: opencode"; return 127; }
            command nono run --profile nolabs-ai/opencode --allow /tmp -- opencode "$@"
          }

          omp() {
            print -u2 "warn：use omp-run to execute OMP via the nono sandbox."
            return 1
          }

          claude() {
            print -u2 "warn：use claude-run to execute claude code via nono sandbox."
            return 1
          }

          opencode() {
            print -u2 "warn：use opencode-run execute opencode via nono sandbox."
            return 1
          }
        '';
      };
    };
}
