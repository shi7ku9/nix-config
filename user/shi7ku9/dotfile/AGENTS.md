# Global Environment

This is a NixOS system managed declaratively with Nix flakes and Home Manager.

## NixOS Guidelines

- Prefer changing the NixOS flake over making imperative system changes.
- Use Nix packages and NixOS/Home Manager options instead of assuming a conventional Linux environment.
- Do not use `find`, `rg`, or similar broad search commands from `~/.nix-profile`, `/nix/store`, or other Nix profile/store directories merely to locate an executable, such as `cmake`. Prefer the project's `nix develop` environment or Nix-aware commands such as `nix shell`, `nix develop`, `nix eval`, and `nix path-info`.
- Do not apply system or Home Manager changes unless explicitly requested.
- Keep credentials and other secrets out of the repository and generated configuration.
