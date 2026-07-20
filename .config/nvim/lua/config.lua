-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Tabs & indentation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.swapfile = false
vim.opt.inccommand = "split"

-- UI
vim.opt.termguicolors = true
vim.opt.guifont = "JetBrainsMono Nerd Font Mono:h12"
vim.opt.laststatus = 3
vim.opt.showtabline = 2 -- always show buffer tabs
vim.opt.pumblend = 0 -- no popup transparency (reduces escape sequences)
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.fileformat = "unix" -- default to unix line endings
vim.opt.cursorline = true
vim.opt.cursorlineopt = "line"

-- Highlight overrides (commented out — now using kanagawa.nvim)
-- vim.api.nvim_create_autocmd("ColorScheme", {
-- 	callback = function()
-- 		vim.api.nvim_set_hl(0, "CursorLine", { bg = "#282C33" })
-- 		local normal_fg = vim.api.nvim_get_hl(0, { id = vim.api.nvim_get_hl_id_by_name("Normal") }).fg
-- 		vim.api.nvim_set_hl(0, "LineNr", { fg = normal_fg })
-- 		vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#282C33", bg = "#101112" })
-- 		vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "#99AE63" })
-- 		vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#D8C27A" })
-- 		vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#B27B78" })
-- 		vim.api.nvim_set_hl(0, "BlinkIndent", { fg = "#383E47" })
-- 		vim.api.nvim_set_hl(0, "BlinkIndentScope", { fg = "#586270" })
-- 		vim.api.nvim_set_hl(0, "StatusLine", { fg = "#BCC5D1", bg = "#101112" })
-- 		vim.api.nvim_set_hl(0, "MiniStatuslineModeNormal", { fg = "#101112", bg = "#99AE63" })
-- 		vim.api.nvim_set_hl(0, "MiniStatuslineModeInsert", { fg = "#101112", bg = "#7495B6" })
-- 		vim.api.nvim_set_hl(0, "MiniStatuslineModeVisual", { fg = "#101112", bg = "#B59CD8" })
-- 		vim.api.nvim_set_hl(0, "MiniStatuslineModeCommand", { fg = "#101112", bg = "#D8C27A" })
-- 		vim.api.nvim_set_hl(0, "MiniStatuslineModeOther", { fg = "#FDFEFF", bg = "#B27B78" })
-- 		vim.api.nvim_set_hl(0, "LspInlayHint", { fg = "#586270", bg = "#101112" })
-- 		vim.api.nvim_set_hl(0, "SnacksPickerDir", { fg = "#878889" })
-- 		vim.api.nvim_set_hl(0, "TabLine", { fg = "#798494", bg = "#282C33" })
-- 		vim.api.nvim_set_hl(0, "TabLineSel", { fg = "#FDFEFF", bg = "#383E47" })
-- 	end,
-- })

-- Statusline mode colors (disabled — use theme defaults instead)
-- vim.api.nvim_create_autocmd("ColorScheme", {
-- 	callback = function()
-- 		vim.api.nvim_set_hl(0, "MiniStatuslineModeNormal", { fg = "#121212", bg = "#dfdfaf" })
-- 		vim.api.nvim_set_hl(0, "MiniStatuslineModeInsert", { fg = "#121212", bg = "#87afaf" })
-- 		vim.api.nvim_set_hl(0, "MiniStatuslineModeVisual", { fg = "#121212", bg = "#af8787" })
-- 		vim.api.nvim_set_hl(0, "MiniStatuslineModeCommand", { fg = "#121212", bg = "#dfaf87" })
-- 		vim.api.nvim_set_hl(0, "MiniStatuslineModeOther", { fg = "#dfdfaf", bg = "#af5f5f" })
-- 		vim.api.nvim_set_hl(0, "LineNr", { fg = "#dfdfaf" })
-- 	end,
-- })

-- Ensure float borders are always visible regardless of colorscheme
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#586270" })
	end,
})
vim.opt.signcolumn = "yes" -- dedicated sign column
vim.opt.sidescrolloff = 8

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- Splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Folds (indentation-based, more predictable than treesitter)
vim.opt.foldmethod = "indent"
vim.opt.foldlevel = 99
vim.opt.foldopen:remove("hor") -- don't open folds on horizontal movement

-- Performance
vim.opt.updatetime = 750
vim.opt.timeoutlen = 300 -- leader completion timeout
vim.opt.ttimeoutlen = 10 -- fast key code processing
vim.opt.scrolloff = 10 -- keep cursor 10 lines from top/bottom

-- Diagnostics
vim.diagnostic.config({
	virtual_text = false, -- NO inline text that runs off screen
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "",
			[vim.diagnostic.severity.WARN] = "",
			[vim.diagnostic.severity.HINT] = "",
			[vim.diagnostic.severity.INFO] = "",
		},
	},
	underline = true, -- Squiggly underline stays
	update_in_insert = false, -- Don't update while typing
	severity_sort = true, -- Errors before warnings
	float = {
		border = "rounded",
		source = true,
		header = "",
	},
})

-- Format on save (just line endings, no auto-format)
vim.api.nvim_create_autocmd("BufWritePre", {
	callback = function()
		local bufnr = vim.api.nvim_get_current_buf()
		vim.bo[bufnr].fileformat = "unix"
	end,
})

-- Mouse hover: show LSP docs after 750ms idle on a word
vim.api.nvim_create_autocmd("CursorHold", {
	callback = function()
		local clients = vim.lsp.get_clients({ bufnr = 0 })
		if #clients > 0 then
			vim.lsp.buf.hover({ border = "rounded" })
		end
	end,
})

-- Find (under <leader>f)
vim.keymap.set("n", "<leader>ff", function()
	Snacks.picker.files({ hidden = true })
end, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", function()
	Snacks.picker.grep({ args = { "--hidden" } })
end, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", function()
	Snacks.picker.buffers()
end, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", function()
	Snacks.picker.help()
end, { desc = "Help tags" })
vim.keymap.set("n", "<leader>fd", function()
	Snacks.picker.diagnostics()
end, { desc = "Diagnostics" })

vim.keymap.set("n", "<leader>fc", function()
	local allowed = { "alduin", "flume", "south", "nordic" }
	local installed = vim.fn.getcompletion("", "color")
	local filtered = vim.tbl_filter(function(name)
		return vim.tbl_contains(allowed, name)
	end, installed)
	vim.ui.select(filtered, {
		prompt = "  Pick a colorscheme",
		format_item = function(item)
			return item
		end,
	}, function(choice)
		if choice then vim.cmd.colorscheme(choice) end
	end)
end, { desc = "Colorschemes" })

vim.keymap.set("n", "<leader>fz", function()
	Snacks.picker.recent()
end, { desc = "Recent files" })
vim.keymap.set("n", "<leader>fp", function()
	local old_cwd = vim.fn.getcwd()
	Snacks.picker.projects({ dev = { "~/dev" } }, function(project)
		if project and project.dir ~= old_cwd then
			-- Close all buffers when switching to a different project
			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				if vim.bo[buf].buflisted then
					pcall(vim.api.nvim_buf_delete, buf, { force = false })
				end
			end
		end
	end)
end, { desc = "Switch project" })
vim.keymap.set("n", "<leader>fw", function()
	Snacks.picker.grep({ args = { "--hidden", "-w", vim.fn.expand("<cword>") } })
end, { desc = "Grep word under cursor" })
vim.keymap.set("n", "<leader>ld", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "<leader>li", vim.lsp.buf.implementation, { desc = "Go to implementation" })
vim.keymap.set("n", "<leader>lk", vim.lsp.buf.hover, { desc = "Hover documentation" })
vim.keymap.set("n", "<leader>lr", vim.lsp.buf.references, { desc = "LSP references" })
vim.keymap.set("n", "<leader>lm", function()
	Snacks.rename.file()
end, { desc = "Rename file" })
vim.keymap.set("n", "<leader>ls", function()
	Snacks.picker.lsp_symbols()
end, { desc = "LSP symbols" })

-- Git (under <leader>g)
vim.keymap.set("n", "<leader>gs", function()
	Snacks.picker.git_status()
end, { desc = "Git status" })
vim.keymap.set("n", "<leader>gb", function()
	Snacks.picker.git_branches()
end, { desc = "Git branches" })
vim.keymap.set("n", "<leader>gc", function()
	Snacks.picker.git_log()
end, { desc = "Git commits" })

-- Undo history (Snacks picker)
vim.keymap.set("n", "<leader>u", function()
	Snacks.picker.undo()
end, { desc = "Undo history" })

-- Gitsigns hunks (under <leader>h)
vim.keymap.set("n", "<leader>hs", "<cmd>lua require'gitsigns'.stage_hunk()<CR>", { desc = "Stage hunk" })
vim.keymap.set("n", "<leader>hr", "<cmd>lua require'gitsigns'.reset_hunk()<CR>", { desc = "Reset hunk" })
vim.keymap.set("n", "<leader>hu", "<cmd>lua require'gitsigns'.undo_stage_hunk()<CR>", { desc = "Undo stage hunk" })
vim.keymap.set("n", "<leader>hp", "<cmd>lua require'gitsigns'.preview_hunk()<CR>", { desc = "Preview hunk" })
vim.keymap.set("n", "<leader>hb", "<cmd>lua require'gitsigns'.blame_line()<CR>", { desc = "Blame line" })
vim.keymap.set("n", "<leader>hj", "<cmd>lua require'gitsigns'.next_hunk()<CR>", { desc = "Next hunk" })
vim.keymap.set("n", "<leader>hk", "<cmd>lua require'gitsigns'.prev_hunk()<CR>", { desc = "Previous hunk" })

-- Formatting (under <leader>m)
vim.keymap.set("n", "<leader>mf", function()
	vim.lsp.buf.format({ async = true, timeout_ms = 10000 })
end, { desc = "Format current file" })

-- Buffer operations (under <leader>b)
local function close_buffer()
	local bufnr = vim.api.nvim_get_current_buf()
	local listed = vim.tbl_filter(function(b)
		return vim.bo[b].buflisted
	end, vim.api.nvim_list_bufs())
	if #listed <= 1 then
		vim.cmd("enew")
		pcall(vim.api.nvim_buf_delete, bufnr, { force = false })
	else
		local idx
		for i, b in ipairs(listed) do
			if b == bufnr then
				idx = i
				break
			end
		end
		local next_buf = listed[(idx % #listed) + 1]
		vim.api.nvim_set_current_buf(next_buf)
		pcall(vim.api.nvim_buf_delete, bufnr, { force = false })
	end
end
vim.keymap.set("n", "<leader>bd", close_buffer, { desc = "Close buffer" })
vim.keymap.set("n", "<leader>x", close_buffer, { desc = "Close buffer" })

-- Buffer navigation (bufferline)
vim.keymap.set("n", "<leader>bp", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>bn", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })

-- Tab / Shift-Tab for buffer navigation
vim.keymap.set("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })

-- File explorer (snacks picker-style)
vim.keymap.set("n", "<leader>e", function()
	Snacks.explorer()
end, { desc = "Toggle file explorer" })

-- Split management
vim.keymap.set("n", "<leader>v", "<cmd>vsplit<CR>", { desc = "Vertical split" })
vim.keymap.set("n", "<leader>-", "<cmd>split<CR>", { desc = "Horizontal split" })
vim.keymap.set("n", "<leader>q", "<C-w>c", { desc = "Close split" })

-- Window navigation via Ctrl+h/j/k/l (move between splits)
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Keymaps viewer
vim.keymap.set("n", "<leader>kk", function()
	require("which-key").show({ global = false })
end, { desc = "Keymaps" })

-- Folding (under <leader>z)
local function toggle_fold_block()
	local closed = vim.fn.foldclosed(".")
	if closed ~= -1 then
		-- Cursor is on a closed fold — open it
		vim.cmd("normal! za")
	else
		-- Cursor is inside an open block — find start and close it
		local level = vim.fn.foldlevel(vim.fn.line("."))
		if level > 0 then
			vim.cmd("normal! [zza")
		end
	end
end
vim.keymap.set("n", "<leader>z", "za", { desc = "Toggle fold" })
vim.keymap.set("n", "<leader>zf", toggle_fold_block, { desc = "Fold/unfold current block" })
vim.keymap.set("n", "<leader>zo", "zR", { desc = "Open all folds" })
vim.keymap.set("n", "<leader>zc", "zM", { desc = "Close all folds" })

-- Diagnostic navigation (under <leader>d)
vim.keymap.set("n", "<leader>dn", "<cmd>lua vim.diagnostic.jump({ count = 1 })<CR>", { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>dp", "<cmd>lua vim.diagnostic.jump({ count = -1 })<CR>", { desc = "Previous diagnostic" })
vim.keymap.set("n", "<leader>dt", function()
	local bufnr = vim.api.nvim_get_current_buf()
	local enabled = vim.diagnostic.is_enabled({ bufnr = bufnr })
	vim.diagnostic.enable(not enabled, { bufnr = bufnr })
end, { desc = "Toggle diagnostics" })

-- Clear search highlight (under <leader>h group, double-tap)
vim.keymap.set("n", "<leader>hh", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Quickfix navigation
vim.keymap.set("n", "]q", "<cmd>cnext<CR>", { desc = "Next quickfix" })
vim.keymap.set("n", "[q", "<cmd>cprev<CR>", { desc = "Previous quickfix" })
