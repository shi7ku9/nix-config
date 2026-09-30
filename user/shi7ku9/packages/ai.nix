{ inputs, ... }:

{
  flake.homeModules."user/shi7ku9" =
    { pkgs, ... }:
    let
      agentPkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
      chatgpt = pkgs.symlinkJoin {
        name = "chatgpt-wayland";
        inherit (agentPkgs.chatgpt) meta;
        paths = [ agentPkgs.chatgpt ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/chatgpt --add-flags "--ozone-platform=wayland"
        '';
      };
    in
    {
      home.packages = [
        agentPkgs.codex
        agentPkgs.omp
        agentPkgs.opencode
        chatgpt
      ];
    };
}
