{ ... }:

{
  flake.homeModules."user/shi7ku9" =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        # system monitor
        fastfetch
        microfetch
        btop

        upower
      ];
    };
}
