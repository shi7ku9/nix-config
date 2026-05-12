# gaming profile 
{config, lib,...}:

let 
  cfg = config.my.profiles.gaming;

    enabaledUser = 
    lib.filterAttrs
      (_: userCfg: userCfg.enable)
      cfg.users;
in {
  options.my.profiles.gaming = {
    enable = lib.mkEnableOption "Open Gaming Profile for NixOS";

    users = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule({name, ...}: {
          options = {
            enable = lib.mkEnableOption "Open Gaming Profile for ${name}";
          };

        })
      );

      default = { };
    };  
  };


  imports = [
    ./programs/steam.nix
  ];
  config = lib.mkIf cfg.enable {

    
    services.flatpak.enable = true;

    home-manager.users = 
      lib.mapAttrs
        (name: _: import ./home-manager.nix)
        enabaledUser;
  };


}
