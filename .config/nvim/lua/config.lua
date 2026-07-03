-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true -- disabled: scroll jitter over SSH

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
vim.opt.laststatus = 3 -- global statusline (one across full width)
vim.opt.pumblend = 0 -- no popup transparency (reduces escape sequences)
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.fileformat = "unix" -- default to unix line endings
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
		vim.api.nvim_set_hl(0, "BlinkIndent", { fg = "#383E47" }) -- crayon medium dark gray
		vim.api.nvim_set_hl(0, "BlinkIndentScope", { fg = "#586270" }) -- crayon medium gray
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

-- Folds (treesitter-powered)
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = ""
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

-- Format on save (via LSP)
vim.api.nvim_create_autocmd("BufWritePre", {
	callback = function()
		-- Force unix line endings
		vim.opt.fileformat = "unix"
		-- Format via LSP
		local clients = vim.lsp.get_clients({ bufnr = 0 })
		if #clients > 0 then
			pcall(vim.lsp.buf.format, { async = false, timeout_ms = 10000 })
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

-- Gitsigns hunks (under <leader>h)
vim.keymap.set("n", "<leader>hs", "<cmd>lua require'gitsigns'.stage_hunk()<CR>", { desc = "Stage hunk" })
vim.keymap.set("n", "<leader>hr", "<cmd>lua require'gitsigns'.reset_hunk()<CR>", { desc = "Reset hunk" })
vim.keymap.set("n", "<leader>hp", "<cmd>lua require'gitsigns'.preview_hunk()<CR>", { desc = "Preview hunk" })
vim.keymap.set("n", "<leader>hu", "<cmd>lua require'gitsigns'.undo_stage_hunk()<CR>", { desc = "Undo stage hunk" })
vim.keymap.set("n", "<leader>hb", "<cmd>lua require'gitsigns'.blame_line()<CR>", { desc = "Blame line" })
vim.keymap.set("n", "<leader>hS", "<cmd>lua require'gitsigns'.stage_buffer()<CR>", { desc = "Stage buffer" })
vim.keymap.set("n", "<leader>hR", "<cmd>lua require'gitsigns'.reset_buffer()<CR>", { desc = "Reset buffer" })
vim.keymap.set(
	"n",
	"<leader>hU",
	"<cmd>lua require'gitsigns'.reset_buffer_index()<CR>",
	{ desc = "Reset buffer index" }
)

-- Formatting (under <leader>m)
vim.keymap.set("n", "<leader>mf", function()
	vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
end, { desc = "Format current file" })
vim.keymap.set("n", "<leader>ma", function()
	local count = 0
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].modified then
			pcall(vim.lsp.buf.format, { bufnr = bufnr, async = true, timeout_ms = 10000 })
			count = count + 1
		end
	end
	vim.notify("Formatted " .. count .. " buffer(s)", vim.log.levels.INFO)
end, { desc = "Format all modified buffers" })

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
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })

-- Split management
vim.keymap.set("n", "<leader>v", "<cmd>vsplit<CR>", { desc = "Vertical split" })
vim.keymap.set("n", "<leader>s", "<cmd>split<CR>", { desc = "Horizontal split" })
vim.keymap.set("n", "<leader>q", "<C-w>c", { desc = "Close split" })
vim.keymap.set("n", "<C-w>", "<C-w>c", { desc = "Close split" })

-- Window navigation via Ctrl+h/j/k/l (move between splits)
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Keymaps viewer
vim.keymap.set("n", "<leader>?", function()
	require("which-key").show({ global = false })
end, { desc = "Keymaps (which-key)" })

-- Folding (under <leader>z)
vim.keymap.set("n", "<leader>z", "za", { desc = "Toggle fold" })
vim.keymap.set("n", "<leader>zR", "zR", { desc = "Open all folds" })
vim.keymap.set("n", "<leader>zM", "zM", { desc = "Close all folds" })

-- Clear search highlight
vim.keymap.set("n", "<leader>h", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Select all
vim.keymap.set("n", "<C-a>", "ggVG", { desc = "Select all" })
