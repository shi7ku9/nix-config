{ self, ... }:

{
  flake.homeModules."profiles/development" =
    { config, pkgs, ... }:
    let
      inherit (config.xdg) cacheHome dataHome stateHome;
    in
    {
      imports = [
        self.homeModules.nvf
      ];
      home.packages = with pkgs; [
        # zig !
        zig
        zls
        lldb

        # rustup!
        rustup

        gopls

        clang
        clang-tools

        # nix
        nixd
        nil
        nixfmt
      ];

      # Keep toolchain state under XDG dirs instead of dotdirs in $HOME.
      xdg.enable = true;
      home.preferXdgDirectories = true;

      # Rust: cargo itself comes from rustup.
      programs.cargo = {
        enable = true;
        package = null;
        cargoHome = "${dataHome}/cargo";
      };
      home.sessionVariables.RUSTUP_HOME = "${dataHome}/rustup";

      # Go: never download toolchains behind Nix's back.
      programs.go = {
        enable = true;
        env = {
          GOPATH = "${dataHome}/go";
          GOTOOLCHAIN = "local";
        };
        telemetry.mode = "off";
      };

      # Node: the Nix store is read-only, so `npm i -g` needs a writable prefix.
      programs.npm = {
        enable = true;
        settings = {
          prefix = "${dataHome}/npm";
          cache = "${cacheHome}/npm";
        };
      };
      programs.pnpm.enable = true;

      # Python >= 3.13 reads PYTHON_HISTORY for the REPL history file.
      home.sessionVariables.PYTHON_HISTORY = "${stateHome}/python_history";

      home.sessionPath = [
        "${dataHome}/cargo/bin"
        "${dataHome}/go/bin"
        "${dataHome}/npm/bin"
      ];

      editorconfig = {
        enable = true;
        settings = {
          "*" = {
            charset = "utf-8";
            end_of_line = "lf";
            insert_final_newline = true;
            trim_trailing_whitespace = true;
            indent_style = "space";
            indent_size = 4;
          };
          "*.{nix,json,jsonc,yaml,yml,toml,js,jsx,ts,tsx,css,html,md,lua}" = {
            indent_size = 2;
          };
          "*.md".trim_trailing_whitespace = false;
          "{*.go,go.mod,Makefile,*.mk}".indent_style = "tab";
        };
      };
    };
}
