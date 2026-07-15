require("lazyload").on_vim_enter(function()
	-- 1. nvim-web-devicons — MUST load first (needed by bufferline + snacks)
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
		delay = 50,
		win = { border = "rounded" },
	})
	require("which-key").add({
		{ "<leader>f", group = "Find", icon = "" },
		{ "<leader>g", group = "Git" },
		{ "<leader>b", group = "Buffer" },
		{ "<leader>d", group = "Diagnostic" },
		{ "<leader>m", group = "Format" },
		{ "<leader>h", group = "Hunk", icon = "" },
		{ "<leader>l", group = "LSP" },
		{ "<leader>t", group = "Test" },
		{ "<leader>z", group = "Fold" },
	})

	-- Add individual mappings to which-key groups (sorted by key)
	require("which-key").add({
		{ "<leader>bd", desc = "Close buffer" },
		{ "<leader>bn", desc = "Next buffer" },
		{ "<leader>bp", desc = "Previous buffer" },
		{ "<leader>dn", desc = "Next diagnostic" },
		{ "<leader>dp", desc = "Previous diagnostic" },
		{ "<leader>dt", desc = "Toggle diagnostics" },
		{ "<leader>e", desc = "Toggle file explorer" },
		{ "<leader>fc", desc = "Colorschemes" },
		{ "<leader>fh", desc = "Help tags" },
		{ "<leader>fp", desc = "Switch project" },
		{ "<leader>fw", desc = "Grep word under cursor" },
		{ "<leader>fz", desc = "Recent files" },
		{ "<leader>hh", desc = "Clear search highlight" },
		{ "<leader>hj", desc = "Next hunk" },
		{ "<leader>hk", desc = "Previous hunk" },
		{ "<leader>hu", desc = "Undo stage hunk" },
		{ "<leader>kk", desc = "Show all keymaps" },
		{ "<leader>lc", desc = "Code action" },
		{ "<leader>ld", desc = "Go to definition" },
		{ "<leader>li", desc = "Go to implementation" },
		{ "<leader>lk", desc = "Hover documentation" },
		{ "<leader>lm", desc = "Rename file" },
		{ "<leader>ln", desc = "Rename symbol" },
		{ "<leader>lr", desc = "LSP references" },
		{ "<leader>ls", desc = "LSP symbols" },
		{ "<leader>tf", desc = "Run test file" },
		{ "<leader>tn", desc = "Run nearest test" },
		{ "<leader>to", desc = "Test output" },
		{ "<leader>ts", desc = "Test summary" },
		{ "<leader>x", desc = "Close buffer" },
		{ "<leader>zc", desc = "Close all folds" },
		{ "<leader>zf", desc = "Fold/unfold current block" },
		{ "<leader>zo", desc = "Open all folds" },
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
		watch_gitdir = { interval = 5000 },
		current_line_blame = false, -- disabled: causes blame lookups per line
		update_debounce = 500,
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

	-- mini.comment — gc to toggle comment (built into mini.nvim)
	require("mini.comment").setup({
		mappings = {
			comment = "gc",
			comment_line = "gcc",
			comment_visual = "gc",
			textobject = "gc",
		},
	})

	-- mini.surround — ys / cs / ds (replaces nvim-surround)
	require("mini.surround").setup({
		mappings = {
			add = "ys",
			delete = "ds",
			find = "sf",
			find_left = "sF",
			highlight = "sh",
			replace = "cs",
			update_n_lines = "sn",
		},
	})

	-- 8. bufferline.nvim — tabufline
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
		},
	})

	-- 9. Terminal (snacks.terminal) — floating toggle via <leader>i
	vim.keymap.set("n", "<leader>i", function()
		Snacks.terminal.toggle(nil, { win = { position = "float", border = "rounded", width = 0.65, height = 0.65 } })
	end, { desc = "Toggle terminal" })
	vim.keymap.set("n", "<A-i>", function()
		Snacks.terminal.toggle(nil, { win = { position = "float", border = "rounded", width = 0.65, height = 0.65 } })
	end, { desc = "Toggle terminal" })
	vim.keymap.set("t", "<A-i>", function()
		Snacks.terminal.toggle(nil, { win = { position = "float", border = "rounded", width = 0.65, height = 0.65 } })
	end, { desc = "Toggle terminal" })

	-- 10. wakatime/vim-wakatime — automatic time tracking
	vim.pack.add({
		{ src = "https://github.com/wakatime/vim-wakatime" },
	})

	-- 11. Periodic auto-save (every 60s, no format)
	vim.defer_fn(function()
		local function auto_save()
			local has_modified = false
			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				if vim.bo[buf].modified and vim.bo[buf].buflisted and vim.fn.bufname(buf) ~= "" then
					has_modified = true
					pcall(vim.cmd, "silent write")
				end
			end
			if has_modified then
				vim.defer_fn(auto_save, 60000)
			end
		end
		auto_save()
	end, 60000)

	-- 13. wrapped.nvim — year-in-review dashboard (:NvimWrapped / :WrappedNvim)
	vim.pack.add({
		{ src = "https://github.com/nvzone/volt" },
	})
	vim.pack.add({
		{ src = "https://github.com/aikhe/wrapped.nvim" },
	})
	vim.keymap.set("n", "<leader>ow", "<cmd>WrappedNvim<CR>", { desc = "Wrapped dashboard" })
end)
