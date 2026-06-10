{ ... }:

{
  flake.nixosModules."services/power-profile" =
    { ... }:
    {
      services.upower.enable = true;

      powerManagement.enable = true;
      powerManagement.powertop.enable = true;

      # Simple static governor – no external package required
      powerManagement.cpuFreqGovernor = "powersave";

    };
}
