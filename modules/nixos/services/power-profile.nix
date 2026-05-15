{ ... }:

{
  flake.nixosModules.power-profile =
    { ... }:
    {
      services.upower.enable = true;

      powerManagement.enable = true;
      powerManagement.powertop.enable = true;
    };
}
