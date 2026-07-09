local M = {}

local function lsp_name()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	if #clients == 0 then
		return nil
	end
	local name
	for _, client in ipairs(clients) do
		if client.name ~= "copilot" and client.name ~= "null-ls" then
			name = client.name
			break
		end
	end
	if not name then
		name = clients[1].name
	end
	return name:gsub("^typescript%-language%-server$", "ts")
		:gsub("^ruby%-lsp$", "ruby")
		:gsub("^rust%-analyzer$", "ra")
		:gsub("^bash-language-server$", "bash")
		:gsub("^yaml-language-server$", "yaml")
		:gsub("^elixirls$", "elixir")
		:gsub("^lua-language-server$", "lua")
		:gsub("^vtsls$", "ts")
end

local function format_size(bytes)
	if bytes <= 0 then
		return ""
	end
	if bytes < 1024 then
		return ("%dB"):format(bytes)
	end
	if bytes < 1024 * 1024 then
		return ("%.1fKB"):format(bytes / 1024)
	end
	return ("%.1fMB"):format(bytes / (1024 * 1024))
end

function M.active()
	local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
	local git = MiniStatusline.section_git({ trunc_width = 75 })
	local diagnostics = MiniStatusline.section_diagnostics({
		trunc_width = 75,
		signs = { ERROR = "E", WARN = "W", INFO = "I", HINT = "I" },
	})

	-- Path relative to project root
	local filename = vim.fn.expand("%:p")
	if filename ~= "" then
		local root = vim.fs.root(0, { ".git" })
		filename = root and filename:sub(#root + 2) or vim.fn.expand("%:t")
	else
		filename = "[No Name]"
	end

	-- Git diff stats from gitsigns
	local diff = ""
	local d = vim.b.gitsigns_status_dict
	if d then
		local parts = {}
		if d.added and d.added > 0 then table.insert(parts, "+" .. d.added) end
		if d.changed and d.changed > 0 then table.insert(parts, "~" .. d.changed) end
		if d.removed and d.removed > 0 then table.insert(parts, "-" .. d.removed) end
		if #parts > 0 then diff = " " .. table.concat(parts, " ") end
	end

	local groups = {
		{ hl = mode_hl, strings = { mode } },
		{ hl = "MiniStatuslineFilename", strings = { git .. diff, filename } },
	}

	-- Right side: only shown when LSP is attached
	local lsp = lsp_name()
	if lsp then
		local right = {}
		table.insert(right, { hl = "MiniStatuslineModeNormal", strings = { lsp } })
		-- Diagnostics count
		table.insert(right, { hl = "MiniStatuslineFileinfo", strings = { diagnostics } })
		local enc = vim.bo.fenc ~= "" and vim.bo.fenc:upper() or nil
		if enc then
			table.insert(right, { hl = "MiniStatuslineFileinfo", strings = { enc } })
		end
		local ff = vim.bo.ff == "unix" and "LF" or vim.bo.ff == "dos" and "CRLF" or ""
		if ff ~= "" then
			table.insert(right, { hl = "MiniStatuslineFileinfo", strings = { ff } })
		end
		local size = format_size(vim.fn.getfsize(vim.fn.expand("%:p")))
		if size ~= "" then
			table.insert(right, { hl = "MiniStatuslineFileinfo", strings = { size } })
		end

		table.insert(groups, "%=")
		for _, g in ipairs(right) do
			table.insert(groups, g)
		end
	end

	return MiniStatusline.combine_groups(groups)
end

return M
