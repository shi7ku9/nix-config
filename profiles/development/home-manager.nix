{ self, ... }:

{
  flake.homeModules.profiles-development =
    { pkgs, ... }:
    {
      imports = [
        self.homeModules.nixvim
      ];
      home.packages = with pkgs; [
        # zig !
        zig
        zls
        lldb

        # rustup!
        rustup

        go
        gopls

        clang
        clang-tools

      ];
    };
}
