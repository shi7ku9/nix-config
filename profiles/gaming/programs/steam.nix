{ ... }:

{
  flake.nixosModules."profiles/gaming" =
    { pkgs, ... }:
    {
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
