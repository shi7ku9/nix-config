{ self, ... }:

{
  flake.homeModules."profiles/development" =
    { pkgs, ... }:
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

        go
        gopls

        clang
        clang-tools

        nodejs
        python3
      ];
    };
}
