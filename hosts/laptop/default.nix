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
        self.nixosModules.host-shiziku-laptop
      ];
    }
  );

  flake.nixosModules.host-shiziku-laptop =
    { pkgs, ... }:
    {

      imports = [
        self.nixosModules.systemd-boot
        self.nixosModules.power-profile
        self.nixosModules.sound-service
        self.nixosModules.bluetooth
        self.nixosModules.keyd

        self.nixosModules.user-shiziku
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

        ripgrep
        eza
        sedutil

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

      # This option defines the first version of NixOS you have installed on this particular machine,
      # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
      #
      # Most users should NEVER change this value after the initial install, for any reason,
      # even if you've upgraded your system to a new NixOS release.
      #
      # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
      # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
      # to actually do that.
      #
      # This value being lower than the current NixOS release does NOT mean your system is
      # out of date, out of support, or vulnerable.
      #
      # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
      # and migrated your data accordingly.
      #
      # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
      system.stateVersion = "25.11"; # Did you read the comment? NO, I can't read !!!
    };

}
