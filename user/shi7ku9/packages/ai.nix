{ inputs, ... }:

{
  flake.homeModules."user/shi7ku9" =
    { pkgs, ... }:
    let
      agentPkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
      codex-desktop =
        inputs.codex-desktop-linux.packages.${pkgs.stdenv.hostPlatform.system}.codex-desktop;
    in
    {
      home.packages = [
        agentPkgs.codex
        agentPkgs.omp
        agentPkgs.opencode
        codex-desktop
      ];

      home.sessionVariables.CODEX_OZONE_PLATFORM = "wayland";
    };
}
