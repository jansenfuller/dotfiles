local M = {}

function M.active()
	local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
	local git = MiniStatusline.section_git({ trunc_width = 75 })
	local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
	local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })

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

	return MiniStatusline.combine_groups({
		{ hl = mode_hl, strings = { mode } },
		{ hl = "MiniStatuslineFilename", strings = { git .. diff, filename } },
		"%=",
		{ hl = "MiniStatuslineFileinfo", strings = { diagnostics, fileinfo } },
	})
end

return M
