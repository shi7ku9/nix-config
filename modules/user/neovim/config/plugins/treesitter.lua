return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPost", "BufNewFile" },
  cmd = { "TSInstall", "TSUpdate" },
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {},
      auto_install = false,
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
