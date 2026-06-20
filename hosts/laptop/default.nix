{
  inputs,
  self,
  withSystem,
  ...
}:

{
  flake.nixosConfigurations.shiziku-laptop = withSystem "x86_64-linux" (
    ctx:
    inputs.nixpkgs.lib.nixosSystem {
      modules = [
        inputs.nixpkgs.nixosModules.readOnlyPkgs
        (
          { ... }:
          {
            nixpkgs.pkgs = ctx.pkgs;
          }
        )
        self.nixosModules.accept-features
        # self.nixosModules.nixpkgs
        self.nixosModules."host/shiziku-laptop"
      ];
    }
  );

  flake.nixosModules."host/shiziku-laptop" =
    { pkgs, ... }:
    {

      imports = [
        self.nixosModules."system/systemd-boot"
        self.nixosModules."services/power-profile"
        self.nixosModules."services/sound-service"
        self.nixosModules."services/bluetooth"
        self.nixosModules."services/keyd"
        self.nixosModules."services/docker"

        self.nixosModules."user/shiziku"
      ];

      nix.settings = {
        trusted-users = [
          "root"
          "@wheel"
        ]; # I Trust YOU!

        fallback = false;
      };

      networking = {
        hostName = "shiziku-laptop";
        networkmanager.enable = true;
        firewall.trustedInterfaces = [ "wlp1s0" ];
      };

      time.timeZone = "Asia/Taipei";

      i18n.defaultLocale = "en_US.UTF-8";

      hardware.cpu.intel.npu.enable = true;
      hardware.graphics.enable = true;

      xdg.portal.enable = true;
      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      xdg.portal.config.common.default = "*";
      services = {
        openssh.enable = true;
        flatpak.enable = true;
      };
      programs.appimage.enable = true;
      security.polkit.enable = true;

      environment.systemPackages = with pkgs; [
        glib
        vim
        curl
        wget

        file
        which
        tree
        findutils
        coreutils

        htop

        icu

        intel-compute-runtime
        intel-ocl
        level-zero
      ];

      system.stateVersion = "25.11"; # Did you read the comment? NO, I can't read !!!
    };

}
