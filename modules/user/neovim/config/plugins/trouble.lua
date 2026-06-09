return {
  "folke/trouble.nvim",
  cmd = "Trouble",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "<leader>ld", "<Cmd>Trouble diagnostics toggle focus=true<CR>", desc = "Diagnostics" },
  },
  config = function()
    require("trouble").setup()
  end,
}
