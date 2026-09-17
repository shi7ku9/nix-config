{ ... }:

{
  flake.homeModules."user/shi7ku9" =
    { ... }:
    {
      programs.codex = {
        enable = true;
        package = null;
        context = ./AGENTS.md;
      };

      programs.opencode = {
        enable = true;
        package = null;
        context = ./AGENTS.md;
      };
    };
}
