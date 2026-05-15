{ ... }:

{
  flake.nixosModules.sound-service =
    { ... }:
    {
      services.pipewire = {
        enable = true;
        pulse.enable = true;
      };
    };
}
