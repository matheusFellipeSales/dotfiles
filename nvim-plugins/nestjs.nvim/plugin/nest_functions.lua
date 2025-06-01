vim.keymap.set("n", "<leader>ts", function()
	require("nest_functions").create_spec_file()
end, { desc = "Criar arquivo de teste .spec.ts" })

vim.api.nvim_create_user_command("Case", function()
	require("nest_functions").make_use_case()
end, {})

-- Keybinding para criar Use Case + teste com a tecla U no explorer
vim.keymap.set("n", "U", function()
	require("nest_functions").make_use_case()
end, { desc = "Criar Use Case + teste" })
