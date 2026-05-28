{ ... }:

{
  flake.homeModules.nixvim =
    { ... }:
    {
      programs.nixvim = {
        globals.mapleader = " ";
        keymaps = [
          {
            action = "<Esc>";
            key = "jj"; # jia jia jia
            mode = [ "i" ];
          }
          {
            action = "<Esc>";
            key = "<f13>";
            mode = ["i" "n" "v"];
          }
          {
            action = "<Cmd>NvimTreeOpen<Enter>";
            key = "<leader>o";
            mode = [ "n" ];
            options.desc = "Open NvimTree";
          }
          {
            action = "<Cmd>NvimTreeToggle<Enter>";
            key = "<leader>e";
            mode = [ "n" ];
            options.desc = "Toggle NvimTree";
          }
          {
            action = "<Cmd>Trouble diagnostics toggle focus=true<Enter>";
            key = "<leader>ld";
            mode = [ "n" ];
            options.desc = "Diagnostics";
          }

        ];
      };
    };
}
