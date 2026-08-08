{ ... }:

{
  flake.homeModules."user/shi7ku9" =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        git
        wl-clipboard
        zed-editor
        vscodium
        nixd
        nil
        nixfmt
      ];
    };
}
