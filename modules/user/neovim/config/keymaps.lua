vim.g.mapleader = " "

local map = vim.keymap.set

map("i", "jj", "<Esc>", { desc = "Exit insert mode" })

map({ "i", "n", "v", "c" }, "<f13>", "<Esc>", { desc = "Escape via F13" })

map("n", "<leader>o", "<Cmd>NvimTreeOpen<CR>", { desc = "Open NvimTree" })
map("n", "<leader>e", "<Cmd>NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })
map("n", "<leader>ld", "<Cmd>Trouble diagnostics toggle focus=true<CR>", { desc = "Diagnostics" })
map("n", "<leader>w", ":w<CR>", { desc = "Save file" })
map("n", "<leader>q", ":q<CR>", { desc = "Quit" })
map("n", "<leader>Q", ":xa<CR>", { desc = "Quit all" })

map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })
map("n", "<leader>=", "<C-w>=", { desc = "Equalize windows" })

map("n", "gd", vim.lsp.buf.definition, { desc = "Definition" })
map("n", "gD", vim.lsp.buf.references, { desc = "References" })
map("n", "gt", vim.lsp.buf.type_definition, { desc = "Type Definition" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Implementation" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
map("n", "<leader>la", vim.lsp.buf.code_action, { desc = "LSP Action" })
map("n", "<leader>lr", vim.lsp.buf.rename, { desc = "Rename Symbols" })
