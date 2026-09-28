{ ... }:

{
  flake.nixosModules."services/gnome-keyring" =
    { ... }:
    {
      # Provides org.freedesktop.secrets (Secret Service) for Electron apps like Claude
      services.gnome.gnome-keyring.enable = true;

      # GUI for managing keyrings
      programs.seahorse.enable = true;

      # Unlock the login keyring with the login password (TTY login)
      security.pam.services.login.enableGnomeKeyring = true;
    };
}
