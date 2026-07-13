local M = {}

-- Cached values (updated via autocmds, not on every redraw)
local cache = setmetatable({}, { __mode = "v" })

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

-- Update cached values only when they change
local group = vim.api.nvim_create_augroup("StatuslineCache", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "LspAttach", "LspDetach" }, {
	group = group,
	callback = function(ev)
		local buf = ev.buf
		cache[buf] = cache[buf] or {}
		cache[buf].lsp = lsp_name()
	end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
	group = group,
	callback = function(ev)
		local buf = ev.buf
		local path = vim.api.nvim_buf_get_name(buf)
		cache[buf] = cache[buf] or {}
		cache[buf].size = format_size(path and vim.fn.getfsize(path) or 0)
	end,
})

vim.api.nvim_create_autocmd("BufWipeout", {
	group = group,
	callback = function(ev)
		cache[ev.buf] = nil
	end,
})

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
		"%=",
	}

	local right = {}
	-- Right side: only shown when LSP is attached
	local buf_cache = cache[vim.api.nvim_get_current_buf()] or {}
	if buf_cache.lsp then
		table.insert(right, { hl = "MiniStatuslineModeNormal", strings = { buf_cache.lsp } })
		table.insert(right, { hl = "MiniStatuslineFileinfo", strings = { diagnostics } })
		local enc = vim.bo.fenc ~= "" and vim.bo.fenc:upper() or nil
		if enc then
			table.insert(right, { hl = "MiniStatuslineFileinfo", strings = { enc } })
		end
		local ff = vim.bo.ff == "unix" and "LF" or vim.bo.ff == "dos" and "CRLF" or ""
		if ff ~= "" then
			table.insert(right, { hl = "MiniStatuslineFileinfo", strings = { ff } })
		end
		if buf_cache.size and buf_cache.size ~= "" then
			table.insert(right, { hl = "MiniStatuslineFileinfo", strings = { buf_cache.size } })
		end
	end
	-- Always show cursor position
	table.insert(right, { hl = "MiniStatuslineFileinfo", strings = { MiniStatusline.section_fileinfo({ trunc_width = 120 }) } })

	for _, g in ipairs(right) do
		table.insert(groups, g)
	end

	return MiniStatusline.combine_groups(groups)
end

return M
