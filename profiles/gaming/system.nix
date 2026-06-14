# gaming profile
{ ... }:

{
  flake.nixosModules."profiles/gaming" =
    { ... }:
    {
      imports = [
        #self.nixosModules."profiles/gaming-steam"
      ];
      programs.gamemode.enable = true;

      services.flatpak.enable = true;

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;

      };

      security.rtkit.enable = false;
    };
}
