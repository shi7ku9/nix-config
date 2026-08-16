{
  inputs,
  self,
  withSystem,
  ...
}:

{
  flake.nixosConfigurations.shi7ku9-laptop = withSystem "x86_64-linux" (
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
        self.nixosModules."host/shi7ku9-laptop"
      ];
    }
  );

  flake.nixosModules."host/shi7ku9-laptop" =
    { pkgs, ... }:
    {

      imports = [
        self.nixosModules."system/systemd-boot"
        self.nixosModules."services/power-profile"
        self.nixosModules."services/sound-service"
        self.nixosModules."services/bluetooth"
        self.nixosModules."services/keyd"
        self.nixosModules."services/docker"
        self.nixosModules."services/envfs"

        self.nixosModules."user/shi7ku9"
      ];

      nix.settings = {
        trusted-users = [
          "root"
          "@wheel"
        ]; # I Trust YOU!

        fallback = false;
      };

      users.users.shi7ku9.extraGroups = [
        "video"
        "render"
      ];

      networking = {
        hostName = "shi7ku9-laptop";
        networkmanager.enable = true;
        firewall.trustedInterfaces = [ "wlp1s0" ];
      };

      time.timeZone = "Asia/Taipei";

      i18n.defaultLocale = "en_US.UTF-8";

      hardware.cpu.intel.npu.enable = true;
      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          intel-compute-runtime
          intel-media-driver
          intel-vaapi-driver
          level-zero
        ];
      };

      xdg.portal.enable = true;
      xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      xdg.portal.config.common.default = "*";
      services = {
        openssh.enable = true;
        flatpak.enable = true;
      };
      programs.appimage.enable = true;
      programs.nix-ld.enable = true;
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
