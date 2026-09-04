local M = {}

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

	-- Git diff stats from gitsigns (buffer-local, already cached by gitsigns)
	local diff = ""
	local d = vim.b.gitsigns_status_dict
	if d then
		local parts = {}
		if d.added and d.added > 0 then
			table.insert(parts, "+" .. d.added)
		end
		if d.changed and d.changed > 0 then
			table.insert(parts, "~" .. d.changed)
		end
		if d.removed and d.removed > 0 then
			table.insert(parts, "-" .. d.removed)
		end
		if #parts > 0 then
			diff = " " .. table.concat(parts, " ")
		end
	end

	-- LSP name (queried directly, not cached — always up to date)
	local lsp = (function()
		local clients = vim.lsp.get_clients({ bufnr = 0 })
		local names = {}
		for _, c in ipairs(clients) do
			if c.name ~= "copilot" and c.name ~= "null-ls" then
				table.insert(names, c.name)
			end
		end
		if #names == 0 and #clients > 0 then
			for _, c in ipairs(clients) do
				table.insert(names, c.name)
			end
		end
		if #names > 0 then
			return table.concat(names, ", ")
		end
		return "No LSP"
	end)()
	local enc = vim.bo.fenc ~= "" and vim.bo.fenc:upper() or nil
	local ff = vim.bo.ff == "unix" and "LF" or vim.bo.ff == "dos" and "CRLF" or ""

	local groups = {
		{ hl = mode_hl, strings = { mode } },
		{ hl = "MiniStatuslineFilename", strings = { git .. diff, filename } },
		"%=",
		{ hl = "MiniStatuslineModeNormal", strings = { lsp } },
		{ hl = "MiniStatuslineFileinfo", strings = { diagnostics } },
	}
	if enc then
		table.insert(groups, { hl = "MiniStatuslineFileinfo", strings = { enc } })
	end
	if ff ~= "" then
		table.insert(groups, { hl = "MiniStatuslineFileinfo", strings = { ff } })
	end
	table.insert(
		groups,
		{ hl = "MiniStatuslineFileinfo", strings = { MiniStatusline.section_fileinfo({ trunc_width = 120 }) } }
	)

	return MiniStatusline.combine_groups(groups)
end

return M
