-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

-- keybinds
lvim.keys.normal_mode["S-h"] = ":bprevious<CR>"
lvim.keys.normal_mode["S-l"] = ":bnext<CR>"

lvim.keys.normal_mode["<C-s>"] = ":w!<CR>"
lvim.keys.normal_mode["<S-x>"] = ":BufferKill<CR>"
lvim.format_on_save = true

-- prettier support
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  {
    command = "prettier",
    filetypes = { "typescript", "typescriptreact" },
  },
}

-- tailwindcss intelicense
require("lvim.lsp.manager").setup "tailwindcss"

-- terminal toggle configuration
lvim.builtin.which_key.mappings["t"] = {
  name = "+Terminal",
  t = { "<cmd>ToggleTerm<cr>", "Floating terminal" },
  v = { "<cmd>2ToggleTerm size=30 direction=vertical<cr>", "Split vertical" },
  h = { "<cmd>2ToggleTerm size=30 direction=horizontal<cr>", "Split horizontal" },
}
