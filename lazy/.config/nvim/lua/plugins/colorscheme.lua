return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },

  -- enable transparent on tokyonight
  {
    "folke/tokyonight.nvim",
    lazy = true,
    priority = 1000,
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },

  -- enable transparent on catppuccin
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
}
