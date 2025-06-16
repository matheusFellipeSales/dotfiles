return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        transparent_background = true,
        integrations = {
          neotree = true,
          mason = true,
          telescope = true,
          treesitter = true,
          treesitter_context = true,
          snacks = true,
          mini = {
            enabled = true,
            indentscope_color = "",
          },
        }
      })
      vim.cmd [[colorscheme catppuccin]]
    end
  },
}
