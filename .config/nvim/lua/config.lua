-- Line numbers
vim.opt.number = true
-- vim.opt.relativenumber = true  -- temporarily disabled: can cause scroll jitter on large files

-- Tabs & indentation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- UI
vim.opt.termguicolors = true
vim.opt.laststatus = 3 -- global statusline (one across full width)
vim.opt.pumblend = 0 -- no popup transparency (reduces escape sequences)
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.cursorline = true
vim.opt.cursorlineopt = "line"

-- Highlight overrides using crayon palette colors (set after colorscheme via autocmd)
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		-- Cursor line: subtle highlight using crayon's dark gray (#282C33)
		vim.api.nvim_set_hl(0, "CursorLine", { bg = "#282C33" })
		-- Window separator: subtle line using crayon's dark gray
		vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#282C33", bg = "#101112" })
		-- Git gutter signs: crayon palette colors
		vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "#99AE63" }) -- crayon green
		vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#D8C27A" }) -- crayon yellow
		vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#B27B78" }) -- crayon red
		-- Indent guides: subtle lines, active scope brighter
		vim.api.nvim_set_hl(0, "IblIndent", { fg = "#383E47" }) -- crayon medium dark gray
		vim.api.nvim_set_hl(0, "IblScope", { fg = "#586270" }) -- crayon medium gray
		-- Statusline: bright text (crayon default is #586270 which is unreadable)
		vim.api.nvim_set_hl(0, "StatusLine", { fg = "#BCC5D1", bg = "#101112" })
		-- Statusline mode colors (lualine-style)
		vim.api.nvim_set_hl(0, "MiniStatuslineModeNormal", { fg = "#101112", bg = "#99AE63" }) -- green
		vim.api.nvim_set_hl(0, "MiniStatuslineModeInsert", { fg = "#101112", bg = "#7495B6" }) -- blue
		vim.api.nvim_set_hl(0, "MiniStatuslineModeVisual", { fg = "#101112", bg = "#B59CD8" }) -- purple
		vim.api.nvim_set_hl(0, "MiniStatuslineModeCommand", { fg = "#101112", bg = "#D8C27A" }) -- yellow
		vim.api.nvim_set_hl(0, "MiniStatuslineModeOther", { fg = "#FDFEFF", bg = "#B27B78" }) -- red
		-- Tabline: brighter selected tab
		vim.api.nvim_set_hl(0, "TabLine", { fg = "#798494", bg = "#282C33" })
		vim.api.nvim_set_hl(0, "TabLineSel", { fg = "#FDFEFF", bg = "#383E47" })
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

-- Show diagnostic float on hover after 750ms idle
vim.api.nvim_create_autocmd("CursorHold", {
	callback = function()
		vim.diagnostic.open_float(nil, {
			scope = "cursor",
			border = "rounded",
			source = true,
			focusable = false,
			prefix = "● ",
		})
	end,
})

-- Format on save (via LSP)
vim.api.nvim_create_autocmd("BufWritePre", {
	callback = function()
		local clients = vim.lsp.get_clients({ bufnr = 0 })
		if #clients > 0 then
			pcall(vim.lsp.buf.format, { async = false, timeout_ms = 10000 })
		end
	end,
})

-- Telescope
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Help tags" })

-- Git (under <leader>g)
vim.keymap.set("n", "<leader>gs", "<cmd>Telescope git_status<CR>", { desc = "Git status" })
vim.keymap.set("n", "<leader>gb", "<cmd>Telescope git_branches<CR>", { desc = "Git branches" })
vim.keymap.set("n", "<leader>gc", "<cmd>Telescope git_commits<CR>", { desc = "Git commits" })

-- Formatting (under <leader>m)
vim.keymap.set("n", "<leader>mf", function()
	vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
end, { desc = "Format current file" })
vim.keymap.set("n", "<leader>ma", function()
	local count = 0
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].modified and vim.bo[bufnr].filetype ~= "" then
			vim.api.nvim_buf_call(bufnr, function()
				pcall(vim.lsp.buf.format, { async = false, timeout_ms = 10000 })
			end)
			count = count + 1
		end
	end
	if count > 0 then
		vim.notify("Formatted " .. count .. " buffer(s)", vim.log.levels.INFO)
	else
		vim.notify("No modified buffers to format", vim.log.levels.INFO)
	end
end, { desc = "Format all modified buffers in CWD" })

-- Close buffer
vim.keymap.set("n", "<leader>x", function()
	local bufnr = vim.api.nvim_get_current_buf()
	local listed = vim.tbl_filter(function(b)
		return vim.bo[b].buflisted
	end, vim.api.nvim_list_bufs())
	if #listed <= 1 then
		-- Last buffer: create empty one, then delete current
		vim.cmd("enew")
		pcall(vim.api.nvim_buf_delete, bufnr, { force = false })
	else
		-- Switch to the next buffer in the list first, then delete
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
end, { desc = "Close buffer" })

-- Buffer navigation (bufferline)
vim.keymap.set("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })

-- File explorer
vim.keymap.set("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })

-- Window navigation via Ctrl+h/j/k/l (move between splits)
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Keymaps viewer
vim.keymap.set("n", "<leader>?", function()
	require("which-key").show({ global = false })
end, { desc = "Keymaps (which-key)" })

-- Clear search highlight
vim.keymap.set("n", "<leader>h", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
