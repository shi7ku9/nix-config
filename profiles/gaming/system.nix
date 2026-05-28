# gaming profile
{ inputs, ... }:

{
  flake.nixosModules.profiles-gaming =
    { ... }:
    {
      imports = [
        #self.nixosModules.profiles-gaming-steam

        inputs.nix-gaming.nixosModules.pipewireLowLatency
      ];
      programs.gamemode.enable = true;

      services.flatpak.enable = true;

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;

        lowLatency = {
          enable = true;
          quantum = 64;
          rate = 48000;
        };
      };

      security.rtkit.enable = true;
    };
}
