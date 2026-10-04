{
  description = "shi7ku9's Home Manager flake (development toolchain + Neovim on Arch Linux)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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
  };

  outputs =
    { flake-parts, self, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {

      systems = [ "x86_64-linux" ];
      imports = [
        inputs.home-manager.flakeModules.home-manager
        (inputs.import-tree ./modules)
        (inputs.import-tree ./user)
        (inputs.import-tree ./profiles)
      ];

      perSystem =
        { ... }:
        let
          pkgsUnstable = import inputs.nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        in
        {
          _module.args.pkgs = pkgsUnstable;

          checks.home-test = self.homeConfigurations.shi7ku9.activationPackage;

          formatter = pkgsUnstable.nixfmt-tree;
        };
    };
}
