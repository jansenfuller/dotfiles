-- Disable unused providers — skip host probing at startup (python3/ruby/perl
-- RPC checks, node health checks) for interpreters this config never uses.
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

-- Silence DEBUG-level vim.notify calls (e.g. tobira.nvim's startup "key is
-- remapped" scan) without touching the plugins that emit them.
-- Re-applied after VimEnter: a plugin that replaces vim.notify wholesale
-- (noice.nvim, nvim-notify) would otherwise silently drop this filter, and
-- the spam would return with no obvious cause.
local function install_notify_filter()
	local inner = vim.notify
	if rawget(vim, "_notify_filter_installed") == inner then
		return
	end
	local wrapper = function(msg, level, opts)
		if level == vim.log.levels.DEBUG then
			return
		end
		return inner(msg, level, opts)
	end
	vim.notify = wrapper
	vim._notify_filter_installed = wrapper
end
install_notify_filter()
vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		vim.schedule(install_notify_filter)
	end,
})

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Tabs & indentation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
-- smartindent is a legacy C-style heuristic that fights both treesitter's
-- indentexpr (set per-filetype in plugin/treesitter.lua) and ftplugin rules,
-- and misindents '#' comments in Ruby/Python/shell. autoindent alone is the
-- correct fallback for filetypes with no indentexpr.
vim.opt.smartindent = false
vim.opt.autoindent = true
vim.opt.swapfile = false
vim.opt.undofile = true -- persistent undo history across sessions
vim.opt.inccommand = "split"

-- UI
vim.opt.termguicolors = true
vim.opt.guifont = "JetBrainsMono Nerd Font Mono:h12"
vim.opt.laststatus = 3
vim.opt.showtabline = 2 -- always show buffer tabs
vim.opt.pumblend = 0 -- no popup transparency (reduces escape sequences)
-- Global float border. Replaces the removed per-map `vim.lsp.buf.hover({border=...})`
-- override (Neovim 0.12 maps K to hover by default, so redefining it just to
-- set a border was redundant) and applies to every float that doesn't opt out.
vim.opt.winborder = "rounded"
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.fileformat = "unix" -- default to unix line endings
vim.opt.cursorline = true
vim.opt.cursorlineopt = "line"

-- Ensure float borders are always visible regardless of colorscheme
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#586270" })
	end,
})
vim.opt.signcolumn = "yes" -- dedicated sign column
vim.opt.sidescrolloff = 8

-- Use snacks.explorer as the file browser (disable netrw)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- Splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Folds: indent-based fallback here for filetypes with no treesitter parser.
-- plugin/treesitter.lua overrides this per-window to foldmethod=expr with
-- vim.treesitter.foldexpr() once a parser attaches — AST-based folds match
-- a block's actual header-to-footer range, so a function's `def foo():`
-- line folds *that* function, not whatever indent-level fold sits above it.
vim.opt.foldmethod = "indent"
vim.opt.foldlevel = 99
vim.opt.foldopen:remove("hor") -- don't open folds on horizontal movement

-- Performance
vim.opt.updatetime = 750
vim.opt.timeoutlen = 300 -- leader completion timeout
vim.opt.ttimeoutlen = 10 -- fast key code processing
vim.opt.scrolloff = 10 -- keep cursor 10 lines from top/bottom

-- Persistent undo (survives restarts; pairs with the undo-history picker)
vim.opt.undofile = true
local undo_dir = vim.fn.stdpath("data") .. "/undo"
vim.fn.mkdir(undo_dir, "p")
vim.opt.undodir = undo_dir

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

-- LSP hover: swallow empty results so the command line doesn't spam
-- "No information available" on every word without docs (CursorHold hover
-- and K both go through this handler)
local default_hover = vim.lsp.handlers["textDocument/hover"]
vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
	if not result or not result.contents then
		return
	end
	if type(result.contents) == "table" and vim.tbl_isempty(result.contents) then
		return
	end
	return default_hover(err, result, ctx, config)
end

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

local extra_colorschemes_added = false
vim.keymap.set("n", "<leader>fc", function()
	-- Alduin/flume/south are only ever needed here, so only add them to rtp
	-- (clone if missing) the first time this picker is opened, not eagerly
	-- at startup.
	if not extra_colorschemes_added then
		vim.pack.add({
			{ src = "https://github.com/AlessandroYorba/Alduin" },
			{ src = "https://github.com/mitander/flume.nvim" },
			{ src = "https://github.com/arnauKL/south.nvim" },
		})
		extra_colorschemes_added = true
	end

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
			-- Closing all buffers is destructive — ask first
			vim.ui.select({ "Yes", "No" }, {
				prompt = "Close all open buffers and switch to " .. project.dir .. "?",
			}, function(choice)
				if choice == "Yes" then
					for _, buf in ipairs(vim.api.nvim_list_bufs()) do
						if vim.bo[buf].buflisted then
							pcall(vim.api.nvim_buf_delete, buf, { force = false })
						end
					end
				end
			end)
		end
	end)
end, { desc = "Switch project" })
vim.keymap.set("n", "<leader>fw", function()
	Snacks.picker.grep({ args = { "--hidden", "-w", vim.fn.expand("<cword>") } })
end, { desc = "Grep word under cursor" })
-- NOTE: <leader>ld/li/lk/lr moved to plugin/lsp.lua's LspAttach autocmd —
-- buffer-local, so they don't silently misfire in buffers with no LSP client.
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

	-- Position of the current buffer within the listed set.
	-- nil when the current buffer isn't listed at all — terminal, help,
	-- explorer/picker, quickfix, grug-far, neotest output, mini.map, etc.
	-- (previously this fell through to `idx % #listed` and threw
	-- "attempt to perform arithmetic on local 'idx'").
	local idx
	for i, b in ipairs(listed) do
		if b == bufnr then
			idx = i
			break
		end
	end

	if not idx then
		-- Not part of the buffer cycle, so don't disturb the listed set —
		-- just dismiss this one. Terminals report as modified and refuse a
		-- soft delete, so fall back to closing the window.
		if not pcall(vim.api.nvim_buf_delete, bufnr, { force = false }) then
			pcall(vim.cmd, "close")
		end
		return
	end

	if #listed <= 1 then
		vim.cmd("enew")
		pcall(vim.api.nvim_buf_delete, bufnr, { force = false })
		return
	end

	local next_buf = listed[(idx % #listed) + 1]
	vim.api.nvim_set_current_buf(next_buf)
	pcall(vim.api.nvim_buf_delete, bufnr, { force = false })
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
vim.keymap.set("n", "<leader>zz", "za", { desc = "Toggle fold" })
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

-- Quickfix navigation
vim.keymap.set("n", "]q", "<cmd>cnext<CR>", { desc = "Next quickfix" })
vim.keymap.set("n", "[q", "<cmd>cprev<CR>", { desc = "Previous quickfix" })
