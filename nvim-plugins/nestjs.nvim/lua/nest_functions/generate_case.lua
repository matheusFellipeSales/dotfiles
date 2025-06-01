local M = {}

local function get_target_dir()
	-- Tenta pegar o diretório atual do item selecionado no explorer do Snacks se estiver aberto
	local explorer_pickers = Snacks.picker.get({ source = "explorer" })
	if #explorer_pickers > 0 then
		local picker = explorer_pickers[1]
		if picker then
			-- Pega o item atual selecionado
			local current_item = picker:current()
			if current_item and current_item.file then
				-- Se é um diretório, usa ele diretamente
				if vim.fn.isdirectory(current_item.file) == 1 then
					return current_item.file
				else
					-- Se é um arquivo, pega o diretório pai
					return vim.fn.fnamemodify(current_item.file, ":h")
				end
			end
		end
	end

	-- Se temos um buffer de arquivo válido, usa o diretório dele
	local buf_path = vim.fn.expand("%:p:h")
	if buf_path and buf_path ~= "" and vim.fn.isdirectory(buf_path) == 1 then
		return buf_path
	end

	-- Fallback para o diretório de trabalho atual
	return vim.fn.getcwd()
end

function M.make_use_case(target_dir)
	vim.ui.input({ prompt = "Nome do UseCase (ex: Faz alguma coisa): " }, function(input)
		if not input or input == "" then
			print("Nome inválido.")
			return
		end

		local class_base = input
			:gsub("[^%w%s]", "")
			:gsub("(%w)(%w*)", function(a, b)
				return a:upper() .. b:lower()
			end)
			:gsub("%s+", "")

		local class_name = class_base .. "UseCase"

		local file_base = class_base:gsub("([A-Z])", "-%1"):gsub("^%-", ""):lower()

		local file_name = file_base .. "-use-case.ts"
		local spec_name = file_base .. "-use-case.spec.ts"

		target_dir = target_dir or get_target_dir()

		-- Debug: mostra onde os arquivos serão criados
		print("Target dir determinado: " .. target_dir)

		local use_case_path = target_dir .. "/" .. file_name
		local spec_path = target_dir .. "/" .. spec_name

		print("Criando arquivo em: " .. use_case_path)

		local use_case_content = string.format(
			[[
import { Injectable } from '@nestjs/common';

type Input = {};

type Output = {};

@Injectable()
export class %s {
  async execute(input: Input): Promise<Output> {}
}
]],
			class_name
		)

		local fd = io.open(use_case_path, "w")
		if fd then
			fd:write(use_case_content)
			fd:close()
			vim.cmd("edit " .. use_case_path)
		else
			print("Erro ao criar o UseCase.")
			return
		end

		vim.schedule(function()
			vim.cmd("edit " .. use_case_path)
			vim.defer_fn(function()
				require("nest_functions.generate_spec").create_spec_file()
			end, 50)
		end)
	end)
end

return M
