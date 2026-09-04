{ inputs, ... }:

{
  flake.homeModules."user/shi7ku9" =
    { pkgs, ... }:
    let
      agentPkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      home.packages = with agentPkgs; [
        skills
        omp
        claude-code
        codex
        opencode
        nono
      ];
    };
}
