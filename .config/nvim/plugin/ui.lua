require("lazyload").on_vim_enter(function()
	-- 1. nvim-web-devicons — MUST load first (needed by nvim-tree)
	vim.pack.add({
		{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	})
	require("nvim-web-devicons").setup({
		default = true,
	})

	-- 2. which-key.nvim — auto-shows leader keybindings popup
	vim.pack.add({
		{ src = "https://github.com/folke/which-key.nvim" },
	})
	require("which-key").setup({
		delay = 50, -- show popup faster when leader is pressed
	})
	require("which-key").add({
		{ "<leader>f", group = "Find", icon = "" },
		{ "<leader>g", group = "Git" },
		{ "<leader>m", group = "Format" },
		{ "<leader>h", group = "Hunk", icon = "" },
		{ "<leader>l", group = "LSP" },
		{ "<leader>z", group = "Fold" },
	})

	-- 3. nvim-colorizer.lua — inline hex/color swatches (CSS only)
	vim.pack.add({
		{ src = "https://github.com/NvChad/nvim-colorizer.lua" },
	})
	require("colorizer").setup({
		filetypes = { "css", "scss", "sass", "less", "html" },
		options = {
			parsers = { css = true },
			display = { mode = "background" },
		},
		lazy_load = true,
	})

	-- 4. blink.indent — fast indent guides
	vim.pack.add({
		{ src = "https://github.com/saghen/blink.indent" },
	})
	require("blink.indent").setup({
		scope = {
			enabled = true,
			indent_at_cursor = true,
		},
	})

	-- 5. gitsigns.nvim — git gutter signs (+ ~ ─)
	vim.pack.add({
		{ src = "https://github.com/lewis6991/gitsigns.nvim" },
	})
	require("gitsigns").setup({
		signs = {
			add = { text = "│" },
			change = { text = "│" },
			delete = { text = "󰍵" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
			untracked = { text = "│" },
		},
		signcolumn = true,
		numhl = true,
		linehl = false,
		word_diff = false,
		watch_gitdir = { interval = 1000 },
		current_line_blame = false, -- disabled: causes blame lookups per line
		update_debounce = 500,
		on_attach = function(bufnr)
			local gs = package.loaded.gitsigns
			local function map(mode, l, r, opts)
				opts = opts or {}
				opts.buffer = bufnr
				vim.keymap.set(mode, l, r, opts)
			end
			map("n", "]h", gs.next_hunk, { desc = "Next hunk" })
			map("n", "[h", gs.prev_hunk, { desc = "Previous hunk" })
		end,
	})

	-- 6. tiny-inline-diagnostic.nvim — inline diagnostics
	vim.pack.add({
		{ src = "https://github.com/rachartier/tiny-inline-diagnostic.nvim" },
	})
	require("tiny-inline-diagnostic").setup({
		preset = "minimal",
		options = {
			throttle = 50,
			softwrap = 40,
			multilines = { enabled = true },
			show_code = false,
			show_source = { enabled = true, if_many = true },
		},
	})

	-- 7. mini.statusline — lightweight statusline
	vim.pack.add({
		{ src = "https://github.com/echasnovski/mini.nvim" },
	})
	require("mini.statusline").setup({
		use_icons = true,
		set_vim_settings = true,
		content = {
			active = require("statusline").active,
		},
	})

	-- 8. bufferline.nvim — NvChad-style tabufline
	local bg_lighter = "#2a2b2e"
	vim.pack.add({
		{ src = "https://github.com/akinsho/bufferline.nvim" },
	})
	require("bufferline").setup({
		highlights = {
			separator = { fg = bg_lighter, bg = nil },
			separator_visible = { fg = bg_lighter, bg = nil },
			separator_selected = { fg = bg_lighter, bg = nil },
		},
		options = {
			mode = "buffers",
			separator_style = "thin",
			always_show_tabline = true,
			show_buffer_close_icons = true,
			show_close_icon = false,
			color_mode = "buffer",
			enforce_regular_tabs = false,
			offsets = {
				{ filetype = "NvimTree", text = "Explorer", highlight = "Directory", padding = 1 },
				{ filetype = "FTerm", text = "Terminal", highlight = "Directory", padding = 1 },
			},
		},
	})

	-- 9. FTerm.nvim — floating terminal (Alt-i, persistent session)
	vim.pack.add({
		{ src = "https://github.com/numToStr/FTerm.nvim" },
	})
	local FTerm = require("FTerm")
	FTerm.setup({
		border = "rounded",
		dimensions = {
			height = 0.53,
			width = 0.53,
		},
	})
	vim.keymap.set("n", "<A-i>", function()
		FTerm:toggle()
	end, { desc = "Toggle terminal" })
	vim.keymap.set("t", "<A-i>", function()
		FTerm:toggle()
	end, { desc = "Toggle terminal" })

	-- 10. nvim-tree.lua — file explorer (tuned for speed, git-aware)
	vim.pack.add({
		{ src = "https://github.com/nvim-tree/nvim-tree.lua" },
	})
	require("nvim-tree").setup({
		sort = {
			sorter = "name",
			folders_first = true,
		},
		view = {
			width = 30,
			side = "left",
		},
		renderer = {
			group_empty = true,
			highlight_git = true,
			icons = {
				show = {
					git = true,
					folder = true,
					file = true,
					folder_arrow = true,
				},
			},
		},
		git = {
			enable = true,
			ignore = false,
		},
		filters = {
			dotfiles = false,
			custom = { "^\\.git$" },
		},
		actions = {
			open_file = {
				quit_on_open = false,
				resize_window = true,
			},
		},
		-- Disable filesystem watchers for speed
		filesystem_watchers = {
			enable = false,
		},
	})

	-- 11. Vim Wrapped
	vim.pack.add({
		{ src = "https://github.com/nvzone/volt" },
	})
	vim.pack.add({
		{ src = "https://github.com/aikhe/wrapped.nvim" },
	})

	-- 12. Smart Paste
	vim.pack.add({
		{ src = "https://github.com/nemanjamalesija/smart-paste.nvim" },
	})

	-- Auto-refresh project diagnostics on open (3s delay for LSP to initialize)
	vim.defer_fn(function()
		require("project_diagnostics").auto_refresh()
	end, 3000)
end)
