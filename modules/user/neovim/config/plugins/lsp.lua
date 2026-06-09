return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("mason").setup()

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local ok, blink = pcall(require, "blink.cmp")
    if ok then
      capabilities = blink.get_lsp_capabilities(capabilities)
    end

    require("mason-lspconfig").setup({
      ensure_installed = {
        "clangd", "gopls", "zls", "nixd", "rust_analyzer",
        "pyright", "ts_ls", "html", "cssls", "jsonls", "yamlls",
      },
      handlers = {
        function(server_name)
          local ok, err = pcall(function()
            local lspconfig = require("lspconfig")
            lspconfig[server_name].setup({ capabilities = capabilities })
          end)
          if not ok then
            vim.notify("LSP setup error for " .. server_name .. ": " .. tostring(err), vim.log.levels.WARN)
          end
        end,
      },
    })
  end,
}
