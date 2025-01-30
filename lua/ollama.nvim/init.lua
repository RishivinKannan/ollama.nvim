local M = {}

-- Function to create a floating window for user input
local function create_floating_win()
	local buf = vim.api.nvim_create_buf(false, true)
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.6)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	})
	vim.api.nvim_buf_set_option(buf, "modifiable", true)
	vim.api.nvim_buf_set_option(buf, "buftype", "prompt")
	vim.fn.prompt_setprompt(buf, "Ask Ollama: ")
	return buf, win
end

-- Function to capture user input and run Ollama
local function on_enter(buf, model)
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local question = table.concat(lines, " ")
	if question ~= "" then
		local cwd = vim.fn.getcwd()
		local full_query = "Context: " .. cwd .. "\n" .. "Question: " .. question
		local cmd = "ollama run " .. model .. " " .. vim.fn.shellescape(full_query)
		local output = vim.fn.system(cmd)
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(output, "\n"))
	end
end

-- Command to open floating window and wait for input
vim.api.nvim_create_user_command("OllamaAsk", function()
	local model = "deepseek-r1:1.5b" -- Default model, change as needed
	local buf, _ = create_floating_win()
	vim.api.nvim_create_autocmd("BufLeave", {
		buffer = buf,
		once = true,
		callback = function()
			on_enter(buf, model)
		end,
	})
end, {})

return M
