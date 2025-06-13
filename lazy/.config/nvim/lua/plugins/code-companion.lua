return {
  -- Code Companion
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      {
        "<C-a>",
        "<cmd>CodeCompanionActions<CR>",
        desc = "Open the action palette",
        mode = { "n", "v" },
      },
      {
        "<Leader>aa",
        "<cmd>CodeCompanionChat Toggle<CR>",
        desc = "Toggle a chat buffer",
        mode = { "n", "v" },
      },
      {
        "<Leader>an",
        "<cmd>CodeCompanionChat New<CR>",
        desc = "Abrir novo chat sem histórico",
        mode = { "n", "v" },
      },
    },
    opts = {
      strategies = {
        chat = {
          adapter = "copilot",
          model = "claude-3-7-sonnet",
        },
        inline = {
          adapter = "copilot",
          model = "claude-3-5-sonnet",
        },
        agent = {
          adapter = "copilot",
          model = "claude-3-5-sonnet",
        },
      },
      log_level = "INFO", -- use "DEBUG" se quiser mais logs
    },
  },

  -- Render markdown bonito no chat
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "codecompanion" },
  },

  -- Copilot (com suporte a nvim-cmp e Code Companion)
  { "github/copilot.vim" },
}
