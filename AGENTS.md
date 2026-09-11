# Repository Guidelines

## Project Overview

Personal NixOS configuration flake for a single-user laptop codenamed `shi7ku9`. Uses **flake-parts** for structure and **import-tree** for automatic module discovery. Targets `x86_64-linux` with `nixos-unstable` as the primary package set and `nixos-25.11` exposed as an opt-in `pkgs-stable` package set, not an automatic fallback.

Key ingredients: Hyprland compositor with Noctalia Shell currently active (DMS retained as an alternative), home-manager, systemd-boot, PipeWire, rootless Podman with Docker CLI compatibility, envfs, and a curated set of user packages spanning AI, gaming, development, and creative tools.

## Architecture & Data Flow

```
flake.nix (flake-parts entry)
  └─ import-tree auto-discovers all .nix files under:
       ├─ modules/    → flake.nixosModules / flake.homeModules
       ├─ user/       → flake.nixosModules / flake.homeModules / flake.homeConfigurations
       ├─ hosts/      → flake.nixosModules (merged into nixosConfigurations)
       └─ profiles/   → flake.nixosModules / flake.homeModules
```

**Module discovery and registration**: `import-tree` discovers `.nix` files under the four roots above. Each discovered file explicitly exports its module key under `flake.nixosModules` or `flake.homeModules`; keys may be path-like or short:
```nix
{ flake.homeModules.nvf = { ... }: { ... }; }
```
Do not infer a key from the filesystem path. `import-tree` handles discovery, while the host/user `imports` lists determine which discovered modules are active.

> **⚠ `git add` before use**: Git-based flakes only see git-tracked files — this is a property of Nix flake evaluation itself, not of import-tree. Newly created `.nix` files won't be visible until staged (`git add <file>` first).

**Same-key merging**: Multiple files can export the same key — flake-parts merges them. Used by `hosts/laptop/default.nix` + `hosts/laptop/hardware.nix` (both export `"host/shi7ku9-laptop"`), `modules/user/nvf/*.nix`, `profiles/gaming/*`, `user/shi7ku9/` dotfiles, and `user/shi7ku9/packages/` category files (each exports `"user/shi7ku9"` with a `home.packages` slice — zero wiring needed).

**Dual-module pattern**: Concerns that span both NixOS and home-manager (desktops, profiles) split into paired files:
- `system.nix` → `flake.nixosModules."…"`
- `home-manager.nix` → `flake.homeModules."…"`

**Composition chain**:
1. `flake.nix` — auto-discovers all modules, defines `pkgs`/`pkgs-stable`
2. `hosts/laptop/default.nix` — defines `nixosConfigurations.shi7ku9-laptop` and imports system modules + `user/shi7ku9`
3. `user/shi7ku9/system.nix` — imports the active Noctalia desktop + gaming NixOS modules and creates the user
4. `user/shi7ku9/home-manager.nix` — defines `homeConfigurations.shi7ku9`, imports the active desktop + profiles + user modules, and composes packages/dotfiles

**Channel split**: `pkgs` = `nixos-unstable` (allowUnfree); `pkgs-stable` = `nixos-25.11` (allowUnfree), selected explicitly per package. Home-manager receives `pkgs-stable` through `extraSpecialArgs`.

## Key Directories

| Directory | Purpose |
|---|---|
| `modules/nixos/system/` | Bootloader configs |
| `modules/nixos/services/` | System services (bluetooth, Podman, envfs, keyd, power, sound) |
| `modules/user/` | Home-manager modules (Zsh/starship, editor, fonts, input method, nvf) |
| `modules/user/nvf/` | Neovim config split across 5 files (entry, plugins, options, LSP, keymaps) |
| `modules/shared/desktop/` | Desktop environments — `noctalia-shell` is active; `dms` is an alternative. Each has system + home sides + a Hyprland Lua config |
| `profiles/gaming/` | Gaming profile (system: gamemode/flatpak/Steam/gamescope; home: launchers/wine/lutris) |
| `profiles/development/` | Development profile (home-manager only: language toolchains + nvf) |
| `user/shi7ku9/` | User system config, home-manager config, dotfiles, and `packages/` (`ai`, `apps`, `cli`, `dev`, `monitoring`, same-key merged) |
| `hosts/laptop/` | Hardware-specific Intel laptop host definition; root/boot labels and network interface assumptions are not portable |

## Development Commands

```bash
# Format all Nix files
nix fmt .

# Syntax/consistency check (no builds or lock-file writes)
nix flake check --no-build --no-write-lock-file

# Full system build
nix build .#nixosConfigurations.shi7ku9-laptop.config.system.build.toplevel

# Apply system config
sudo nixos-rebuild switch --flake .#shi7ku9-laptop

# Apply home-manager config
home-manager switch --flake .#shi7ku9
```

**Pre-commit hook** (`.githooks/pre-commit`): runs `nix fmt .` then `nix flake check --no-build`. Install with:
```bash
git config core.hooksPath .githooks
```

## Code Conventions & Common Patterns

### Module export pattern
Every discovered `.nix` file returns a self-registering attribute set:
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

For home-manager modules, use `flake.homeModules` and choose an explicit key consistent with the existing composition.

### Module key naming
- Use explicit keys under `flake.nixosModules` or `flake.homeModules`; do not assume the key is derived from the filename.
- Prefer path-like strings for grouped modules: `"services/bluetooth"` rather than `services.bluetooth`.
- Existing intentional exceptions include `modules/user/nvf/*.nix` → `nvf`, `modules/shared/desktop/dms/{system,home-manager}.nix` → `"desktop/dms"`, and `user/shi7ku9/*` → `"user/shi7ku9"`.
- Before adding an `imports` entry, check whether the new file should merge into an existing same-key module instead.

### Dual-module files
When a concern needs both NixOS and home-manager config:
```
module-folder/
  system.nix        → flake.nixosModules."key"
  home-manager.nix  → flake.homeModules."key"
```

### Package channel choice
- Use `pkgs` (`nixos-unstable`) as the primary package set.
- Use `pkgs-stable` (`nixos-25.11`) only when a package explicitly needs the stable set; it is not a system fallback.
- Home-manager modules receive `pkgs-stable` as a function argument through `extraSpecialArgs`.

### Formatter
`nixfmt-tree` (aliased as `pkgs.nixfmt-tree` in flake.nix `perSystem.formatter`)

## Important Files

| File | Role |
|---|---|
| `flake.nix` | Central orchestrator — inputs, flake-parts imports, system args, checks, formatter |
| `hosts/laptop/default.nix` | Host entry point — `nixosConfigurations.shi7ku9-laptop`, module imports, hostname/locale/system packages |
| `hosts/laptop/hardware.nix` | Hardware — kernel modules, filesystems, swap, microcode |
| `user/shi7ku9/system.nix` | User-level NixOS config — creates the `shi7ku9` user, imports desktop + gaming |
| `user/shi7ku9/home-manager.nix` | Home-manager config — `homeConfigurations.shi7ku9`, profile/desktop/module imports, `programs.git`/`nh`; packages live in `user/shi7ku9/packages/` |
| `modules/user/nvf/nvf.nix` | Neovim entry point — imports nvf flake module, sets theme + languages |
| `profiles/gaming/system.nix` | Gaming system module — gamemode and flatpak; Steam/gamescope are merged from `profiles/gaming/programs/steam.nix` |
| `profiles/development/home-manager.nix` | Development home module — language toolchains, imports nvf |
| `user/shi7ku9/packages/ai.nix` | AI CLI packages from `llm-agents.nix`; wrapper behavior is defined in `user/shi7ku9/dotfile/zsh.nix` |

## Runtime/Tooling Preferences

- **Nix**: `nixos-unstable` primary channel, `nixos-25.11` available as opt-in `pkgs-stable`, flakes enabled, `allowUnfree = true`
- **Formatter**: `nixfmt-tree`
- **Bootloader**: systemd-boot (EFI)
- **Desktop**: Hyprland (Wayland) with `noctalia-shell` active; `dms-shell` is the maintained alternative module
- **Audio**: PipeWire with PulseAudio compatibility
- **Shell**: Zsh with starship prompt, autosuggestions, syntax highlighting, and `~/.local/bin` on `PATH`
- **Editor**: Vim is the default `EDITOR`/`VISUAL`; nvf still configures Neovim with the catppuccin-frappe theme but `defaultEditor = false`

## Operational & Security Notes

- `hosts/laptop/default.nix` enables OpenSSH, envfs, `nix-ld`, and AppImage support, and trusts `wlp1s0` in the firewall. These are host-specific policies; review them before copying the host module.
- Podman is enabled for rootless use with a Docker-compatible CLI alias; rootless pruning runs through a Home Manager user timer. Do not assume a Docker daemon, Docker socket, or privileged container access.
- `user/shi7ku9/dotfile/zsh.nix` intentionally routes `omp` through the `nono` wrapper `omp-run`; `opencode` runs directly.
- The `sandbox` alias uses bubblewrap with a read-only outer filesystem, writable current directory/cache, and a temporary `/tmp`; `SANDBOX=1` marks the shell prompt. The shell sources credentials from `~/.serect/.env`; never commit, print, or copy that file.

## Testing & QA

- **Flake checks** in `flake.nix` → `perSystem.checks`:
  - `nixos-test` — builds the full `nixosConfigurations.shi7ku9-laptop.config.system.build.toplevel`
  - `home-test` — builds `homeConfigurations.shi7ku9.activationPackage`
- **Pre-commit**: `nix fmt .` + `nix flake check --no-build`
- No dedicated test framework or VM test; the checks validate the system and home-manager derivations, while `--no-build` only evaluates them
- The `.gitignore` excludes `/result` (build symlinks) and `.aider*` files
