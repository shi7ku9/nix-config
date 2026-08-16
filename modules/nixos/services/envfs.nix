{ ... }:

{
  flake.nixosModules."services/envfs" =
    { ... }:
    {
      services.envfs.enable = true;
    };
}
