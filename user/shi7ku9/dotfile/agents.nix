{ ... }:

{
  flake.homeModules."user/shi7ku9" =
    { ... }:
    {
      home.file.".omp/agent/AGENTS.md".source = ./AGENTS.md;

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
