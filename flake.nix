{
  description = "shiziku's NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    import-tree.url = "github:denful/import-tree";

    nix-gaming.url = "github:fufexan/nix-gaming";

    nvf.url = "github:notashelf/nvf";
  };

  outputs =
    { flake-parts, self, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {

      systems = [ "x86_64-linux" ];
      imports = [
        inputs.home-manager.flakeModules.home-manager
        (inputs.import-tree ./modules)
        (inputs.import-tree ./user)
        (inputs.import-tree ./hosts)
        (inputs.import-tree ./profiles)
      ];

      flake = {
        nixosModules = {
          accept-features = {
            nix.settings.experimental-features = [
              "nix-command"
              "flakes"
            ];
          };
        };

      };

      perSystem =
        { pkgs, system, ... }:
        {
          _module.args = {
            pkgs = import inputs.nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };

            pkgs-stable = import inputs.nixpkgs-stable {
              inherit system;
              config.allowUnfree = true;
            };
          };

          checks = {
            nixos-test = self.nixosConfigurations.shiziku-laptop.config.system.build.toplevel;

            home-test = self.homeConfigurations.shiziku.activationPackage;
          };

          formatter = pkgs.nixfmt-tree;
        };
    };
}
