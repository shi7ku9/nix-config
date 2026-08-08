# gaming profile
{ ... }:

{
  flake.nixosModules."profiles/gaming" =
    { ... }:
    {
      programs.gamemode.enable = true;

      services.flatpak.enable = true;
    };
}
