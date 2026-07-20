{ self, ... }:

{
  flake.nixosModules."user/shiziku" =
    { pkgs, ... }:
    {
      imports = [
        self.nixosModules."desktop/noctalia-shell"
        self.nixosModules."profiles/gaming"
      ];
      programs.zsh.enable = true;
      users.users.shiziku = {
        isNormalUser = true;
        extraGroups = [
          "wheel" # enable sudo
          "networkmanager"
          "docker"
        ];
        shell = pkgs.zsh;
      };
    };
}
