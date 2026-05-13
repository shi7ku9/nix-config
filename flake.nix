{
  description = "shiziku's NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = {self, nixpkgs, home-manager, ...}@inputs: {
    nixosConfigurations.shiziku-laptop = 
      nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = {inherit inputs;};
        
        modules = [
          ./hosts/laptop

          # --- user ---
          home-manager.nixosModules.home-manager 
          
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = {inherit inputs;};
          }
          ./user/shiziku
        ];
      };
   };
}
