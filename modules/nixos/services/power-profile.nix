{ ... }:

{
  flake.nixosModules."services/power-profile" =
    { ... }:
    {
      services.upower.enable = true;

      powerManagement.enable = true;
      powerManagement.powertop.enable = true;

      powerManagement.cpuFreqGovernor = "powersave";

    };
}
