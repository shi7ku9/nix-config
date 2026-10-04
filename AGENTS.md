# Repository Guidelines

## Project Overview

Personal Home Manager flake for `shi7ku9`, running on **Arch Linux** (non-NixOS). It manages the **development toolchain**, **Neovim (nvf)**, and a fresh set of dotfiles (zsh + starship, git, kitty, direnv). Uses **flake-parts** for structure and **import-tree** for automatic module discovery. Targets `x86_64-linux` with `nixos-unstable`.

This repo used to be a full NixOS configuration. The system, desktop (Hyprland/Noctalia), gaming, input method, fonts and AI CLIs were deliberately removed, and the old dotfiles were rewritten from scratch rather than carried over:
- System, desktop, GPU-related software and system services → pacman.
- AI CLIs and fast-moving apps → AUR (Nix lags behind).

Do not re-add those concerns here.

## Architecture & Data Flow

```
flake.nix (flake-parts entry)
  └─ import-tree auto-discovers all .nix files under:
       ├─ modules/    → flake.homeModules (nvf, zsh, git, kitty, direnv)
       ├─ user/       → flake.homeModules / flake.homeConfigurations
       └─ profiles/   → flake.homeModules
```

**Module discovery and registration**: each discovered file explicitly exports its module key under `flake.homeModules`. Do not infer a key from the filesystem path; `import-tree` only discovers, the `imports` lists decide what is active.
```nix
{ flake.homeModules.nvf = { ... }: { ... }; }
```

> **⚠ `git add` before use**: Git-based flakes only see git-tracked files. Stage newly created `.nix` files before evaluating.

**Composition chain**:
1. `flake.nix` — auto-discovers modules, defines `pkgs` (nixos-unstable, allowUnfree)
2. `user/shi7ku9@shi7ku9-arch/home-manager.nix` — defines `homeConfigurations.shi7ku9`, enables `targets.genericLinux`, imports `profiles/development`
3. `profiles/development/home-manager.nix` — language toolchains + Nix tooling, imports `nvf`
4. `modules/user/nvf/*.nix` — Neovim config (same-key `nvf` modules merged by flake-parts)

## Key Directories

| Directory | Purpose |
|---|---|
| `modules/user/` | Home-manager modules: `zsh` (+ starship), `git`, `kitty`, `direnv` |
| `modules/user/nvf/` | Neovim config split across 5 files (entry, plugins, options, LSP, keymaps) |
| `profiles/development/` | Development profile: language toolchains, Nix tooling, nvf |
| `user/shi7ku9@shi7ku9-arch/` | Home-manager entry (`homeConfigurations.shi7ku9`) |

## Development Commands

```bash
# Format all Nix files
nix fmt .

# Evaluate checks (no builds)
nix flake check --no-build

# Apply home-manager config
nix run home-manager -- switch --flake .#shi7ku9   # first time
home-manager switch --flake .#shi7ku9              # afterwards
```

**Pre-commit hook** (`.githooks/pre-commit`): runs `nix fmt .` then `nix flake check --no-build`. Install with:
```bash
git config core.hooksPath .githooks
```

## Conventions

- Explicit, path-like module keys (`"profiles/development"`); exceptions: `nvf`, `"user/shi7ku9"`.
- Same-key files merge (e.g. all `modules/user/nvf/*.nix` export `nvf`).
- Formatter: `nixfmt-tree`.
- Nix runs in multi-user mode via `nix-daemon.socket` (Arch `nix` package); `/nix/store` must exist with `root:nixbld` mode `1775`.
- Do not use Conventional Commits.
