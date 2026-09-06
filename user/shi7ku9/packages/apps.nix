{ ... }:

{
  flake.homeModules."user/shi7ku9" =
    {
      pkgs,
      pkgs-stable,
      inputs,
      ...
    }:
    let
      zen-unwrapped =
        inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.zen-browser-unwrapped.overrideAttrs
          (old: {
            # Current nixpkgs wrapFirefox reads withFFmpeg; the Zen flake only exposes the legacy flag.
            passthru = (old.passthru or { }) // {
              withFFmpeg = true;
            };
          });
      zen-browser = pkgs.wrapFirefox zen-unwrapped { pname = "zen-browser"; };
    in
    {
      home.packages =
        (with pkgs; [
          kitty
          zen-browser
          vesktop
        ])
        ++ (with pkgs-stable; [
          krita
          blender
        ]);
    };
}
