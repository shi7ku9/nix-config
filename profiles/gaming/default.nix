# gaming profile
{ self, ... }:

{
  flake.nixosModules.profiles-gaming =
    { ... }:
    {
      imports = [
        self.nixosModules.profiles-gaming-steam
      ];
      services.flatpak.enable = true;

    };
}
