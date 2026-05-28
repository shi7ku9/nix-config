{ ... }:

{

  flake.homeModules.nixvim =
    { ... }:
    {
      programs.nixvim = {
        plugins = {
          #lazy.enable = true; I'm Lazy to config Lazy. lol
          snacks.enable = true;
          noice.enable = true;
          web-devicons.enable = true;
          nvim-tree.enable = true;
          telescope = {
            enable = true;
            keymaps = {
              "<leader>fg" = {
                action = "live_grep";
                options.desc = "Live Grep";
              };
              "<leader>ff" = {
                action = "find_files";
                options.desc = "Find Files";
              };
              "<leader>fb" = {
                action = "buffers";
                options.desc = "Buffers";
              };
            };
          };
        };

      };

    };
}
