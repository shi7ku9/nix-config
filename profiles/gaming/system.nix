# gaming profile
{ ... }:

{
  flake.nixosModules."profiles/gaming" =
    { ... }:
    {
      imports = [
        #self.nixosModules."profiles/gaming-steam"
      ];
      programs.gamemode.enable = true;

      services.flatpak.enable = true;
    };
}
