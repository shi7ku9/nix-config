{
  description = "shi7ku9's NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    llm-agents.url = "github:numtide/llm-agents.nix";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    import-tree.url = "github:denful/import-tree";

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia/cachix";
      inputs.nixpkgs.follows = "nixpkgs"; # this line is optional, prevents downloading two versions of nixpkgs but disables cache
    };
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
        { ... }:
        let
          system = "x86_64-linux";
          pkgsUnstable = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          pkgsStable = import inputs.nixpkgs-stable {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          _module.args = {
            pkgs = pkgsUnstable;
            pkgs-stable = pkgsStable;
          };

          checks = {
            nixos-test = self.nixosConfigurations.shi7ku9-laptop.config.system.build.toplevel;

            home-test = self.homeConfigurations.shi7ku9.activationPackage;
          };

          formatter = pkgsUnstable.nixfmt-tree;
        };
    };
}
