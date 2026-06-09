return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  config = function()
    require("conform").setup({
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        -- Increase timeout to avoid frequent aborts on large files
        return { timeout_ms = 500, lsp_fallback = true }
      end,
    })
  end,
}
