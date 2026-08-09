{ ... }:

{
  flake.homeModules."user/shi7ku9" =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        skills
      ];
    };
}
