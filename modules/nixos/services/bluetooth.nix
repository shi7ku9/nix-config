{ ... }:

{
  flake.nixosModules."services/bluetooth" =
    { ... }:
    {
      hardware.bluetooth.enable = true;

      services.blueman.enable = true;
    };
}
