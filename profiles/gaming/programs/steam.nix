{config, lib, pkgs,...}:
let
  cfg = config.my.profiles.gaming;  
in
{
  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfreePredicate = 
      pkg: builtins.elem (lib.getName pkg) [
        "steam"
        "steam-unwrapped"
    ];

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; 
      dedicatedServer.openFirewall = true;
      extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
    };

    programs.gamescope = {
      enable = true;
      capSysNice = false;
    };

    environment.systemPackages = with pkgs; [
      steam-run
    ];
  };
}