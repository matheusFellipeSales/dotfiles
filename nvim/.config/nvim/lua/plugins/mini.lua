return {
  {
    'echasnovski/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup()
      require('mini.pairs').setup()
      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }
      statusline.section_location = function()
        return '%2l:%-2v'
      end
    end,
  },
  {
    "echasnovski/mini.icons",
    lazy = false,
    opts = {
      extension = {
        -- Test icons
        ["spec.ts"] = { glyph = "󰙨", hl = "MiniIconsOrange" },
        ["e2e-spec.ts"] = { glyph = "󰙨", hl = "MiniIconsOrange" },
        ["gateway-spec.ts"] = { glyph = "󰙨", hl = "MiniIconsOrange" },

        -- Nest js
        ["module.ts"] = { glyph = "", hl = "MiniIconsRed" },
        ["service.ts"] = { glyph = "", hl = "MiniIconsYellow" },
        ["controller.ts"] = { glyph = "", hl = "MiniIconsBlue" },
        ["guard.ts"] = { glyph = "", hl = "MiniIconsGreen" },
      },
    },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },
}
