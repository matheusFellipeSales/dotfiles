return {
  'nvim-telescope/telescope.nvim',
  lazy = false,
  keys = {
    { "<leader>sf", "<cmd>Telescope find_files<cr>" },
    { "<leader>sg", "<cmd>Telescope live_grep<cr>" }
  },
  tag = '0.1.8',
  dependencies = {
    'nvim-lua/plenary.nvim',
    "nvim-telescope/telescope-ui-select.nvim"
  },
  config = function()
    require("telescope").load_extension("ui-select")
  end
}
