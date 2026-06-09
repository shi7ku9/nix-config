return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  cmd = { "TSInstall", "TSUpdate" },
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "bash", "lua", "make", "markdown", "nix", "toml", "yaml",
        "zig", "cpp", "c", "go",
      },
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
