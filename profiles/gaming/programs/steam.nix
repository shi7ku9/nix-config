{ inputs, ... }:

{
  flake.nixosModules.profiles-gaming =
    { pkgs, ... }:
    {
      imports = [
        inputs.nix-gaming.nixosModules.platformOptimizations
      ];
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        extraCompatPackages = with pkgs; [
          proton-ge-bin
        ];

        # nix-gaming
        platformOptimizations.enable = true;
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
