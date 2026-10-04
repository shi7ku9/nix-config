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

      extraSpecialArgs = { inherit inputs; };
      modules = [
        self.homeModules."user/shi7ku9"
      ];
    }
  );

  flake.homeModules."user/shi7ku9" = {
    home.username = "shi7ku9";
    home.homeDirectory = "/home/shi7ku9";

    imports = [
      self.homeModules."profiles/development"

      self.homeModules.zsh
      self.homeModules.git
      self.homeModules.kitty
      self.homeModules.direnv
    ];

    # Non-NixOS (Arch): integrate with the host system
    targets.genericLinux.enable = true;

    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep 6 --keep-since 7d";
      flake = "/home/shi7ku9/Code/nix-config";
    };

    home.stateVersion = "26.05";
  };
}
