{ ... }:

{
  flake.nixosModules."services/docker" =
    { ... }:
    {
      virtualisation.docker.enable = true;
      virtualisation.docker.autoPrune.enable = true;
    };
}
