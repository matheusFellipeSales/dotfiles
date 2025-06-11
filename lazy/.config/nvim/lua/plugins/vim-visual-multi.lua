return {
  {
    "mg979/vim-visual-multi",
    lazy = false,
    enable = true,
    branch = "master",
    init = function()
      vim.g.VM_add_cursor_at_pos_no_mappings = 1
    end,
  },
}
