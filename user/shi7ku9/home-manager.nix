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

    ];

    # Non-NixOS (Arch): integrate with the host system
    targets.genericLinux.enable = true;

    home.stateVersion = "26.05";
  };
}
