{ inputs, self, ... }:

{
  flake.homeConfigurations.shiziku = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
    modules = [
      self.homeModules.allow-unfree
      self.homeModules.user-shiziku
    ];
    extraSpecialArgs = { inherit inputs; };
  };

  flake.homeModules.user-shiziku =
    { pkgs, ... }:
    {
      home.username = "shiziku";
      home.homeDirectory = "/home/shiziku";

      imports = [
        self.homeModules.user-shiziku-default-applications
        self.homeModules.desktop-dms
        self.homeModules.profiles-gaming

        self.homeModules.zsh
        self.homeModules.input-method
        self.homeModules.icon-fonts
      ];

      home.packages = with pkgs; [
        # system monitor
        fastfetch
        microfetch
        btop

        # archive
        zip
        unzip
        p7zip
        zstd
        gzip
        bzip2
        xz

        # network
        curl
        wget
        netcat
        traceroute

        # utils
        ripgrep
        eza
        sedutil
        skim
        util-linux
        less

        kitty
        firefox
        upower

        # social blah blah blah
        vesktop

        # dev blah blah blah
        git

        #tool
        krita
        blender

        vscodium
        nixd
        nil
        nixfmt
      ];

      programs.git = {
        enable = true;
        settings = {
          user = {
            name = "shiziku";
            email = "228161658+shi7ku9@users.noreply.github.com";
          };
        };
      };

      programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep 6 --keep-since 7d";
        flake = "/home/shiziku/.nixos";
      };

      home.stateVersion = "26.05";
    };
}
