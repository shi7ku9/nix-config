# Repository Guidelines

## Project Overview

Personal NixOS configuration flake for a single-user laptop codenamed `shiziku`. Uses **flake-parts** for structure and **import-tree** for automatic module discovery. Targets `x86_64-linux` on `nixos-unstable` with a `nixos-25.11` stable channel fallback.

Key ingredients: Hyprland compositor, home-manager, systemd-boot, PipeWire, and a curated set of user packages spanning gaming, development, and creative tools.

## Architecture & Data Flow

```
flake.nix (flake-parts entry)
  └─ import-tree auto-discovers all .nix files under:
       ├─ modules/    → flake.nixosModules / flake.homeModules
       ├─ user/       → flake.nixosModules / flake.homeModules / flake.homeConfigurations
       ├─ hosts/      → flake.nixosModules (merged into nixosConfigurations)
       └─ profiles/   → flake.nixosModules / flake.homeModules
```

**Module self-registration**: Every `.nix` file exports itself under a path-derived key:
```nix
{ flake.nixosModules."services/bluetooth" = { config, ... }: { ... }; }
```
`import-tree` maps the filesystem path to the module key. No manual `imports` needed.

**Same-key merging**: Multiple files can export the same key — import-tree merges them. Used by `hosts/laptop/default.nix` + `hosts/laptop/hardware.nix` (both export `"host/shiziku-laptop"`) and `user/shiziku/` dotfiles (all export `"user/shiziku"`).

**Dual-module pattern**: Concerns that span both NixOS and home-manager (desktops, profiles) split into paired files:
- `system.nix` → `flake.nixosModules."…"`
- `home-manager.nix` → `flake.homeModules."…"`

**Composition chain**:
1. `flake.nix` — auto-discovers all modules, defines `pkgs`/`pkgs-stable`
2. `hosts/laptop/default.nix` — `nixosSystem` importing system modules + `user/shiziku`
3. `user/shiziku/system.nix` — imports desktop + profile NixOS modules, creates user
4. `user/shiziku/home-manager.nix` — imports desktop + profile + user modules, defines packages

**Channel split**: `pkgs` = `nixos-unstable` (allowUnfree); `pkgs-stable` = `nixos-25.11` (allowUnfree). Injected via `_module.args` for NixOS, `extraSpecialArgs` for home-manager.

## Key Directories

| Directory | Purpose |
|---|---|
| `modules/nixos/system/` | Bootloader configs |
| `modules/nixos/services/` | System services (bluetooth, keyd, power, sound) |
| `modules/user/` | Home-manager modules (zsh, fonts, input method, neovim) |
| `modules/user/nvf/` | Neovim config split across 5 files (entry, plugins, options, LSP, keymaps) |
| `modules/shared/desktop/` | Desktop environments — `dms` and `noctalia-shell`, each with system + home sides + Hyprland Lua configs |
| `profiles/gaming/` | Gaming profile (system: gamemode/flatpak; home: launchers/wine/lutris; steam sub-module) |
| `profiles/development/` | Development profile (home-manager only: language toolchains + nvf) |
| `user/shiziku/` | User system config, home-manager config, and dotfiles |
| `hosts/laptop/` | Laptop host definition + hardware config |

## Development Commands

```bash
# Format all Nix files
nix fmt .

# Syntax/consistency check (no builds)
nix flake check --no-build

# Full build dry-run
nix build .#nixosConfigurations.shiziku-laptop.config.system.build.toplevel

# Apply system config
sudo nixos-rebuild switch --flake .#shiziku-laptop

# Apply home-manager config
home-manager switch --flake .#shiziku
```

**Pre-commit hook** (`.githooks/pre-commit`): runs `nix fmt .` then `nix flake check --no-build`. Install with:
```bash
git config core.hooksPath .githooks
```

## Code Conventions & Common Patterns

### Module export pattern
Every `.nix` file returns a self-registering attribute set:
```nix
# modules/nixos/services/bluetooth.nix
{ ... }:
{
  flake.nixosModules."services/bluetooth" = { config, lib, pkgs, ... }: {
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
  };
}
```

For home-manager modules, use `flake.homeModules` with the same path-key convention.

### Module key naming
- **Path-like strings**, not nested attrsets: `"services/bluetooth"` not `services.bluetooth`
- Key = relative path from watched root, minus `.nix` extension
- Directory nesting in key: `modules/shared/desktop/dms/system.nix` → `"desktop/dms"`

### Dual-module files
When a concern needs both NixOS and home-manager config:
```
module-folder/
  system.nix        → flake.nixosModules."key"
  home-manager.nix  → flake.homeModules."key"
```

### Package channel choice
- Use `pkgs-stable` for packages that need stability (e.g., wine, proprietary software)
- Use `pkgs` (unstable) for most other packages
- Reference `pkgs-stable` via `config._module.args.pkgs-stable` in NixOS modules, or receive it as a function argument when wired

### Formatter
`nixfmt-tree` (aliased as `pkgs.nixfmt-tree` in flake.nix `perSystem.formatter`)

## Important Files

| File | Role |
|---|---|
| `flake.nix` | Central orchestrator — inputs, flake-parts imports, system args, checks, formatter |
| `hosts/laptop/default.nix` | Host entry point — `nixosSystem` invocation, module imports, hostname/locale/system packages |
| `hosts/laptop/hardware.nix` | Hardware — kernel modules, filesystems, swap, microcode |
| `user/shiziku/system.nix` | User-level NixOS config — creates the `shiziku` user, imports desktop + gaming |
| `user/shiziku/home-manager.nix` | Home-manager config — packages, dotfiles, profile imports, desktop imports |
| `modules/user/nvf/nvf.nix` | Neovim entry point — imports nvf flake module, sets theme + languages |
| `profiles/gaming/system.nix` | Gaming system module — gamemode, flatpak |
| `profiles/development/home-manager.nix` | Development home module — language toolchains, imports nvf |

## Runtime/Tooling Preferences

- **Nix**: `nixos-unstable` channel, flakes enabled, `allowUnfree = true`
- **Formatter**: `nixfmt-tree`
- **Bootloader**: systemd-boot (EFI)
- **Desktop**: Hyprland (Wayland) via either `dms-shell` or `noctalia-shell` module
- **Audio**: PipeWire with PulseAudio compatibility
- **Shell**: Zsh with starship prompt, autosuggestions, syntax highlighting
- **Editor**: Neovim via `nvf` (community Neovim flake), catppuccin-frappe theme

## Testing & QA

- **Flake checks** in `flake.nix` → `perSystem.checks`:
  - `nixos-test` — builds the full `nixosConfigurations.shiziku-laptop.config.system.build.toplevel`
  - `home-test` — builds `homeConfigurations.shiziku.activationPackage`
- **Pre-commit**: `nix fmt .` + `nix flake check --no-build`
- No dedicated test framework; correctness is validated by building the system and home configurations
- The `.gitignore` excludes `/result` (build symlinks) and `.aider*` files
