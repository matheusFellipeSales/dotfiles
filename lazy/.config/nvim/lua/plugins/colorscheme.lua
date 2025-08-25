return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
    opts = {
      transparent_background = true,
      no_bold = true,
    },
    specs = {
      {
        "akinsho/bufferline.nvim",
        init = function()
          local bufline = require("catppuccin.groups.integrations.bufferline")
          function bufline.get()
            return bufline.get_theme()
          end
        end,
      },
    },
  },
  {
    "tokyonight.nvim",
    lazy = true,
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },
}
