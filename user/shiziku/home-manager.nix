{ pkgs, ... }:

{
  imports = [
    ../../modules/user/zsh.nix
    ../../modules/user/input-method.nix
    ../../modules/user/icon-fonts.nix
    ./default-applications.nix
  ];

  home.username = "shiziku";
  home.homeDirectory = "/home/shiziku";

  home.packages = with pkgs; [
    # system monitor
    fastfetch
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
}
