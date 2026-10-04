{ ... }:

{
  flake.homeModules.kitty = {
    programs.kitty = {
      enable = true;
      themeFile = "Catppuccin-Frappe";
      settings = {
        confirm_os_window_close = 0;
        enable_audio_bell = false;
      };
    };
  };
}
