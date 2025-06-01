local M = {}

function M.create_spec_file()
	local path = vim.api.nvim_buf_get_name(0)
	if path == "" then
		print("Nenhum arquivo aberto.")
		return
	end

	local file = vim.fn.fnamemodify(path, ":t:r")
	local dir = vim.fn.fnamemodify(path, ":p:h")
	local spec_file = dir .. "/" .. file .. ".spec.ts"

	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

	local class_name = nil
	local dependencies = {}

	for _, line in ipairs(lines) do
		local cls = line:match("^%s*export%s+class%s+(%w+)")
		if cls and not class_name then
			class_name = cls
		end

		local dep, from = line:match("import%s+{?%s*(%w+)%s*}?.-from%s+['\"](.+)['\"]")
		if dep and from:sub(1, 2) == "./" then
			table.insert(dependencies, { name = dep, path = from })
		end
	end

	if not class_name then
		print("Classe principal não encontrada.")
		return
	end

	local import_lines = {}
	local mock_lines = {}
	local before_lines = {}
	local let_lines = {}

	table.insert(import_lines, string.format("import { %s } from './%s';", class_name, file))

	for _, dep in ipairs(dependencies) do
		table.insert(import_lines, string.format("import { %s } from '%s';", dep.name, dep.path))
		table.insert(mock_lines, string.format("vi.mock('%s');", dep.path))
		table.insert(let_lines, string.format("let %s: %s;", dep.name:sub(1, 1):lower() .. dep.name:sub(2), dep.name))
		table.insert(
			before_lines,
			string.format("    %s = new %s();", dep.name:sub(1, 1):lower() .. dep.name:sub(2), dep.name)
		)
	end

	local main_var = class_name:sub(1, 1):lower() .. class_name:sub(2)
	table.insert(let_lines, string.format("let %s: %s;", main_var, class_name))
	table.insert(before_lines, string.format("    %s = new %s();", main_var, class_name))

	local content = table.concat(import_lines, "\n")
		.. "\n\n"
		.. table.concat(mock_lines, "\n")
		.. "\n\n"
		.. string.format("describe('%s', () => {\n", class_name)
		.. table.concat(let_lines, "\n")
		.. "\n\n"
		.. "  beforeEach(() => {\n"
		.. table.concat(before_lines, "\n")
		.. "\n"
		.. "  });\n\n"
		.. string.format("  it('should be defined', async () => {\n    expect(%s).toBeDefined();\n  });\n", main_var)
		.. "});\n"

	local fd = io.open(spec_file, "w")
	if fd then
		fd:write(content)
		fd:close()
		vim.cmd("edit " .. spec_file)
		print("Spec file criado: " .. spec_file)
	else
		print("Erro ao criar spec file.")
	end
end

return M
