{ pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
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

  ];
}
