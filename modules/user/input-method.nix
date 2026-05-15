{ ... }:

{
  flake.homeModules.input-method =
    { pkgs, ... }:
    {
      i18n.inputMethod = {
        type = "fcitx5";
        enable = true;
        fcitx5.addons = with pkgs; [
          fcitx5-mozc
          rime-data
          fcitx5-rime
          fcitx5-gtk
          fcitx5-nord
        ];
      };
    };
}
