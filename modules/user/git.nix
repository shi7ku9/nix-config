{ ... }:

{
  flake.homeModules.git = {
    programs.git = {
      enable = true;
      settings = {
        user = {
          name = "shi7ku9";
          email = "228161658+shi7ku9@users.noreply.github.com";
        };
        init.defaultBranch = "main";
      };
    };
  };
}
