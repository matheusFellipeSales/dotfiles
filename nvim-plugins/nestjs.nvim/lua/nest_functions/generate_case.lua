local M = {}

local function get_neotree_selected_path()
	-- Função específica para pegar o caminho selecionado no neo-tree
	local success, neotree_manager = pcall(require, "neo-tree.sources.manager")
	if not success then
		return nil
	end

	local state = neotree_manager.get_state("filesystem")
	if not state or not state.tree then
		return nil
	end

	local node = state.tree:get_node()
	if not node then
		return nil
	end

	local path = node:get_id()
	if node.type == "directory" then
		return path
	else
		return vim.fn.fnamemodify(path, ":h")
	end
end

local function get_target_dir()
	-- Primeiro tenta pegar o diretório do neo-tree
	local neotree_path = get_neotree_selected_path()
	if neotree_path then
		return neotree_path
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
