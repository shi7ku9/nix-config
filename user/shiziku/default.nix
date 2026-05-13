{ pkgs, ... }:

{
  imports = [
    ../../modules/user/desktop/dms

    ../../profiles/gaming
  ];
  my.desktop.dms.enable = true;
  my.desktop.dms.users.shiziku.enable = true;

  my.profiles.gaming.enable = true;
  my.profiles.gaming.users.shiziku.enable = true;

  programs.zsh.enable = true;

  users.users.shiziku = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  home-manager.users.shiziku = import ./home-manager.nix;
}
