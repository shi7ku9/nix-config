{ ... }:

{
  flake.homeModules."user/shi7ku9" =
    {
      pkgs,
      pkgs-stable,
      inputs,
      ...
    }:
    {
      home.packages =
        (with pkgs; [
          kitty
          inputs.zen-browser.packages.x86_64-linux.default
          vesktop
        ])
        ++ (with pkgs-stable; [
          krita
          blender
        ]);
    };
}
