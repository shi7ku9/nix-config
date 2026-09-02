{
  inputs,
  self,
  withSystem,
  ...
}:

{
  flake.homeConfigurations.shi7ku9 = withSystem "x86_64-linux" (
    ctx:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = ctx.pkgs;

      extraSpecialArgs = {
        inherit inputs;
        pkgs-stable = ctx.pkgs-stable;
      };
      modules = [
        self.homeModules."user/shi7ku9"
      ];
    }
  );

  flake.homeModules."user/shi7ku9" =
    { ... }:
    {
      home.username = "shi7ku9";
      home.homeDirectory = "/home/shi7ku9";

      imports = [
        self.homeModules."desktop/noctalia-shell"
        self.homeModules."profiles/gaming"
        self.homeModules."profiles/development"

        self.homeModules.zsh
        self.homeModules.editor
        self.homeModules.input-method
        self.homeModules.icon-fonts
      ];

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

      programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep 6 --keep-since 7d";
        flake = "/home/shi7ku9/.nixos";
      };

      home.stateVersion = "26.05";
    };
}
