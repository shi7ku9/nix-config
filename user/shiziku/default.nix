{pkgs, ...}:

{
  imports = [
    ../../profiles/desktop/dms
  ];
  my.desktop.dms.enable = true;
  my.desktop.dms.users.shiziku.enable = true;
  programs.zsh.enable = true;

  users.users.shiziku = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
  };

  home-manager.users.shiziku = import ./home-manager.nix;
}
