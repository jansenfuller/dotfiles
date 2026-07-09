local M = {}

local function lsp_indicator()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	if #clients == 0 then
		return { text = "no", hl = "MiniStatuslineNoLSP" }
	end
	-- Use the most relevant client name (skip generic ones like "copilot" or "efm")
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
	-- Shorten common server names
	local short = name:gsub("^typescript%-language%-server$", "ts")
		:gsub("^ruby%-lsp$", "ruby")
		:gsub("^rust%-analyzer$", "rust-analyzer")
		:gsub("^bash-language-server$", "bash")
		:gsub("^yaml-language-server$", "yaml")
		:gsub("^elixirls$", "elixir")
		:gsub("^lua-language-server$", "lua")
		:gsub("^vtsls$", "ts")
	return { text = short, hl = "MiniStatuslineModeNormal" }
end

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

	-- LSP indicator
	local lsp = lsp_indicator()

	return MiniStatusline.combine_groups({
		{ hl = mode_hl, strings = { mode } },
		{ hl = "MiniStatuslineFilename", strings = { git .. diff, filename } },
		"%=",
		{ hl = lsp.hl, strings = { lsp.text } },
		{ hl = "MiniStatuslineFileinfo", strings = { diagnostics, fileinfo } },
	})
end

return M
