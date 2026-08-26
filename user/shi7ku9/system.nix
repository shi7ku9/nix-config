{ self, ... }:

{
  flake.nixosModules."user/shi7ku9" =
    { pkgs, ... }:
    {
      imports = [
        self.nixosModules."desktop/noctalia-shell"
        self.nixosModules."profiles/gaming"
      ];
      programs.zsh.enable = true;
      users.users.shi7ku9 = {
        isNormalUser = true;
        home = "/home/shi7ku9";
        createHome = true;
        extraGroups = [
          "wheel" # enable sudo
          "networkmanager"
        ];
        shell = pkgs.zsh;
      };
    };
}
