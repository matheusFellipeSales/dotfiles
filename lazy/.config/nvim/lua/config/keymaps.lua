-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local opts = { noremap = true, silent = true }

-- centralize search results
vim.keymap.set("n", "<C-d>", "<C-d>zz", opts)
vim.keymap.set("n", "<C-u>", "<C-u>zz", opts)
vim.keymap.set("n", "n", "nzzzv", opts)
vim.keymap.set("n", "N", "Nzzzv", opts)

-- better scape
vim.keymap.set("i", "jj", "<Esc>", opts)
vim.keymap.set("i", "jk", "<Esc>", opts)

-- Paste without replacing
vim.keymap.set("v", "p", '"_dP', opts)
vim.keymap.set("n", "x", '"_x', opts)

-- Delete all buffers
vim.keymap.set("n", "<leader>ba", function()
  Snacks.bufdelete.all()
end, opts)

vim.keymap.set("n", "<leader>yp", ":CopyAbsPath<CR>", { desc = "Copy absolute path" })
vim.keymap.set("n", "<leader>yr", ":CopyRelPath<CR>", { desc = "Copy relative path" })
