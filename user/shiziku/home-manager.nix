{
  inputs,
  self,
  withSystem,
  ...
}:

{
  flake.homeConfigurations.shiziku = withSystem "x86_64-linux" (
    ctx:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = ctx.pkgs;

      extraSpecialArgs = {
        inherit inputs;
        pkgs-stable = ctx.pkgs-stable;
      };
      modules = [
        self.homeModules."user/shiziku"
      ];
    }
  );

  flake.homeModules."user/shiziku" =
    { pkgs, pkgs-stable, ... }:
    {
      home.username = "shiziku";
      home.homeDirectory = "/home/shiziku";

      imports = [
        self.homeModules."desktop/dms"
        self.homeModules."profiles/gaming"
        self.homeModules."profiles/development"

        self.homeModules.zsh
        self.homeModules.input-method
        self.homeModules.icon-fonts
      ];

      home.packages =
        (with pkgs; [
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
          wl-clipboard
          zed-editor
          vscodium
          nixd
          nil
          nixfmt

          # AI
          aider-chat
        ])
        ++ (with pkgs-stable; [
          krita
          blender
        ]);

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

      home.file."greeting.txt".text = "Hey\n";
    };
}
