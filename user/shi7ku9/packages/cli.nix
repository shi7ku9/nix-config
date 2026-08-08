{ ... }:

{
  flake.homeModules."user/shi7ku9" =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # archive
        zip
        unzip
        p7zip
        zstd
        gzip
        bzip2
        xz

        # network
        netcat
        traceroute

        # utils
        ripgrep
        eza
        sedutil
        skim
        util-linux
        less
      ];
    };
}
