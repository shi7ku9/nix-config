{ inputs, ... }:

{
  flake.homeModules."user/shi7ku9" =
    { pkgs, ... }:
    let
      agentPkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
      gsettingsSchemaDirs = [
        "${pkgs.gtk3}/share/gsettings-schemas/gtk+3-${pkgs.gtk3.version}/glib-2.0/schemas"
        "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/gsettings-desktop-schemas-${pkgs.gsettings-desktop-schemas.version}/glib-2.0/schemas"
      ];
      chatgpt = pkgs.symlinkJoin {
        name = "chatgpt-with-gsettings";
        paths = [ agentPkgs.chatgpt ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram "$out/bin/chatgpt" \
            --set GSETTINGS_SCHEMA_DIR "${pkgs.lib.concatStringsSep ":" gsettingsSchemaDirs}"
        '';
      };
    in
    {
      home.packages = with agentPkgs; [
        skills
        omp
        chatgpt
        codex
        opencode
        nono
      ];
    };
}
