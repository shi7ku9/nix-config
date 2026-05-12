{pkgs, ... }:

{
  imports = [
      ../../modules/nixos/system/systemd-boot.nix
      ../../modules/nixos/system/networking.nix
      ../../modules/nixos/system/locale.nix
      ../../modules/nixos/services/sound-services.nix
      ../../modules/nixos/services/bluetooth.nix
      ../../modules/nixos/services/power-profile.nix
      
      ../../hosts/laptop/hardware.nix
  ];

  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  services.flatpak.enable = true;

  networking.hostName = "shiziku-laptop"; # Define your hostname.

  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
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
  system.stateVersion = "25.11"; # Did you read the comment?

}

