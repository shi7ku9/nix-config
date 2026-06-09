
return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Live Grep" },
    { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find Files" },
    { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
  },
  config = function()
    require("telescope").setup({
      defaults = {
        mappings = {
          i = { ["<f13>"] = require("telescope.actions").close },
          n = { ["<f13>"] = require("telescope.actions").close },
        },
      },
    })
  end,
}
