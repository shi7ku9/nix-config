{ ... }:

{
  flake.nixosModules."services/podman" =
    { ... }:
    {
      virtualisation.podman = {
        enable = true;
        dockerCompat = true;
      };
    };
}
