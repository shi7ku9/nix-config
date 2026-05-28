{...}:
{
  flake.nixosModules.keyd =
  { ... }:
  {
    services.keyd = {
      enable = true;

      keyboards = {
        default = {
          ids = [ "*" ];
          settings = {
            main = {
              capslock = "f13"; # I dont need capslock!
              rightshift = "rightshift"; # I need right!
              rightcontrol = "rightcontrol";
              rightalt = "rightalt";
            };
          };
        };
      }
      ;
    };
  };

}