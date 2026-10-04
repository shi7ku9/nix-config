{ ... }:

{
  flake.homeModules.kitty = {
    programs.kitty = {
      enable = true;
      # GL apps from Nix cannot reach Arch's GPU drivers; the binary comes from pacman.
      package = null;
      themeFile = "Catppuccin-Frappe";
      settings = {
        confirm_os_window_close = 0;
        enable_audio_bell = false;
      };
    };
  };
}
