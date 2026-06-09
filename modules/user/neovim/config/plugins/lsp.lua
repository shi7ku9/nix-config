return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lspconfig = require("lspconfig")
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local ok, blink = pcall(require, "blink.cmp")
    if ok then
      capabilities = blink.get_lsp_capabilities(capabilities)
    end

    -- Servers installed via Nix (extraPackages in neovim.nix)
    local servers = {
      "clangd", "gopls", "zls", "nixd", "rust_analyzer",
      "pyright", "ts_ls", "html", "cssls", "jsonls", "yamlls",
    }

    for _, server_name in ipairs(servers) do
      local ok, err = pcall(function()
        lspconfig[server_name].setup({ capabilities = capabilities })
      end)
      if not ok then
        vim.notify("LSP setup error for " .. server_name .. ": " .. tostring(err), vim.log.levels.WARN)
      end
    end
  end,
}
