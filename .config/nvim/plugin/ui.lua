local lazyload = require("lazyload")

lazyload.on_vim_enter(function()
	-- All plugins used in this file, added to rtp in one batch instead of one
	-- vim.pack.add() call per plugin. nvim-web-devicons must resolve before
	-- bufferline/snacks require() it, which is satisfied here since nothing
	-- below requires anything until after this call returns.
	vim.pack.add({
		{ src = "https://github.com/nvim-tree/nvim-web-devicons" }, -- 1.
		{ src = "https://github.com/folke/which-key.nvim" }, -- 2.
		{ src = "https://github.com/saghen/blink.indent" }, -- 4.
		{ src = "https://github.com/lewis6991/gitsigns.nvim" }, -- 5.
		{ src = "https://github.com/rachartier/tiny-inline-diagnostic.nvim" }, -- 6.
		{ src = "https://github.com/echasnovski/mini.nvim" }, -- 7.
		{ src = "https://github.com/akinsho/bufferline.nvim" }, -- 8.
		{ src = "https://github.com/wakatime/vim-wakatime" }, -- 10.
		{ src = "https://github.com/kamegoro/tobira.nvim" }, -- 14.
	})

	-- 1. nvim-web-devicons — MUST load first (needed by bufferline + snacks)
	require("nvim-web-devicons").setup({
		default = true,
	})

	-- 2. which-key.nvim — auto-shows leader keybindings popup
	require("which-key").setup({
		delay = 50,
		win = { border = "rounded" },
		plugins = {
			presets = {
				operators = false,
				motions = false,
				text_objects = false,
				windows = false,
				nav = false,
				z = false,
				g = false,
			},
		},
	})
	-- Group labels only. Per-key descriptions come from each vim.keymap.set
	-- call's `desc` field — which-key reads those automatically, so a
	-- hand-maintained duplicate list here would just drift out of sync.
	require("which-key").add({
		{ "<leader>f", group = "Find", icon = "" },
		{ "<leader>g", group = "Git" },
		{ "<leader>b", group = "Buffer" },
		{ "<leader>d", group = "Diagnostic" },
		{ "<leader>m", group = "Format" },
		{ "<leader>h", group = "Hunk", icon = "" },
		{ "<leader>l", group = "LSP" },
		{ "<leader>t", group = "Test" },
		{ "<leader>z", group = "Fold" },
		{ "<leader>o", group = "Other" },
	})

	-- 4. blink.indent — fast indent guides
	require("blink.indent").setup({
		scope = {
			enabled = true,
			indent_at_cursor = true,
		},
	})

	-- 5. gitsigns.nvim — git gutter signs (+ ~ ─)
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
		numhl = false, -- sign column + statusline diff counts already cover this
		linehl = false,
		word_diff = false,
		watch_gitdir = { interval = 5000 },
		current_line_blame = false, -- disabled: causes blame lookups per line
		update_debounce = 500,
		preview_config = { border = "rounded" },
	})

	-- 6. tiny-inline-diagnostic.nvim — inline diagnostics
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

	-- 14. tobira.nvim — vim command learning from usage habits
	lazyload.pack_load({
		{ src = "https://github.com/kamegoro/tobira.nvim" },
	})
	require("tobira").setup({})
end)

-- ═══════════════════════════════════════════════════════════════
-- After first paint (UIEnter + schedule) — non-essential UI chrome.
-- UIEnter never fires headless, so these also skip `nvim --headless`.
-- ═══════════════════════════════════════════════════════════════
lazyload.on_ui_enter(function()
	-- 2. which-key.nvim — auto-shows leader keybindings popup
	lazyload.pack_load({
		{ src = "https://github.com/folke/which-key.nvim" },
	})
	require("which-key").setup({
		delay = 50,
		win = { border = "rounded" },
		plugins = {
			presets = {
				operators = false,
				motions = false,
				text_objects = false,
				windows = false,
				nav = false,
				z = false,
				g = false,
			},
		},
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
		{ "<leader>-", desc = "Horizontal split" },
		{ "<leader>bd", desc = "Close buffer" },
		{ "<leader>bn", desc = "Next buffer" },
		{ "<leader>bp", desc = "Previous buffer" },
		{ "<leader>dn", desc = "Next diagnostic" },
		{ "<leader>dp", desc = "Previous diagnostic" },
		{ "<leader>dt", desc = "Toggle diagnostics" },
		{ "<leader>e", desc = "Toggle file explorer" },
		{ "<leader>fb", desc = "Buffers" },
		{ "<leader>fd", desc = "Diagnostics" },
		{ "<leader>ff", desc = "Find files" },
		{ "<leader>fg", desc = "Live grep" },
		{ "<leader>fh", desc = "Help tags" },
		{ "<leader>fp", desc = "Switch project" },
		{ "<leader>fr", desc = "Find & replace" },
		{ "<leader>fw", desc = "Grep word under cursor" },
		{ "<leader>fz", desc = "Recent files" },
		{ "<leader>gb", desc = "Git branches" },
		{ "<leader>gc", desc = "Git commits" },
		{ "<leader>gs", desc = "Git status" },
		{ "<leader>hb", desc = "Blame line" },
		{ "<leader>hj", desc = "Next hunk" },
		{ "<leader>hk", desc = "Previous hunk" },
		{ "<leader>hp", desc = "Preview hunk" },
		{ "<leader>hr", desc = "Reset hunk" },
		{ "<leader>hs", desc = "Stage hunk" },
		{ "<leader>hu", desc = "Undo stage hunk" },
		{ "<leader>i", desc = "Toggle terminal" },
		{ "<leader>kk", desc = "Show all keymaps" },
		{ "<leader>lc", desc = "Code action" },
		{ "<leader>ld", desc = "Go to definition" },
		{ "<leader>li", desc = "Go to implementation" },
		{ "<leader>lk", desc = "Hover documentation" },
		{ "<leader>lm", desc = "Rename file" },
		{ "<leader>ln", desc = "Rename symbol" },
		{ "<leader>lr", desc = "LSP references" },
		{ "<leader>ls", desc = "LSP symbols" },
		{ "<leader>mm", desc = "Toggle minimap" },
		{ "<leader>ow", desc = "Wrapped dashboard" },
		{ "<leader>q", desc = "Close split" },
		{ "<leader>tf", desc = "Run test file" },
		{ "<leader>tn", desc = "Run nearest test" },
		{ "<leader>to", desc = "Test output" },
		{ "<leader>ts", desc = "Test summary" },
		{ "<leader>u", desc = "Undo history" },
		{ "<leader>v", desc = "Vertical split" },
		{ "<leader>x", desc = "Close buffer" },
		{ "<leader>zc", desc = "Close all folds" },
		{ "<leader>zf", desc = "Fold/unfold current block" },
		{ "<leader>zo", desc = "Open all folds" },
		{ "<leader>zz", desc = "Toggle fold" },
	})

	-- 4. blink.indent — fast indent guides
	lazyload.pack_load({
		{ src = "https://github.com/saghen/blink.indent" },
	})
	require("blink.indent").setup({
		scope = {
			enabled = true,
			indent_at_cursor = true,
		},
	})

	-- 5. gitsigns.nvim — git gutter signs (+ ~ ─)
	lazyload.pack_load({
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
		preview_config = { border = "rounded" },
	})

	-- 6. tiny-inline-diagnostic.nvim — inline diagnostics
	lazyload.pack_load({
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

	-- 8. bufferline.nvim — tabufline
	local bg_lighter = "#2a2b2e"
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

	-- 9. Terminal (snacks.terminal) — floating toggle via <leader>i / <A-i>
	local function toggle_terminal()
		Snacks.terminal.toggle(nil, { win = { position = "float", border = "rounded", width = 0.65, height = 0.65 } })
	end
	vim.keymap.set("n", "<leader>i", toggle_terminal, { desc = "Toggle terminal" })
	vim.keymap.set("n", "<A-i>", toggle_terminal, { desc = "Toggle terminal" })
	vim.keymap.set("t", "<A-i>", toggle_terminal, { desc = "Toggle terminal" })

	-- 10. wakatime/vim-wakatime — automatic time tracking

	-- 11. Periodic auto-save (every 60s, no format)
	vim.defer_fn(function()
		local function auto_save()
			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				if vim.bo[buf].modified and vim.bo[buf].buflisted and vim.fn.bufname(buf) ~= "" then
					-- nvim_buf_call runs `write` with `buf` as current buffer
					-- (and restores the real current buffer after), instead
					-- of always writing whatever buffer happens to be active.
					pcall(vim.api.nvim_buf_call, buf, function()
						vim.cmd("silent write")
					end)
				end
			end
			-- Always reschedule — a quiet tick (nothing modified) must not
			-- permanently kill the timer for the rest of the session.
			vim.defer_fn(auto_save, 60000)
		end
		auto_save()
	end, 60000)

	-- 13. wrapped.nvim — year-in-review dashboard (:WrappedNvim)
	-- Lazily loaded: two plugins (plus its `volt` dependency) for a novelty
	-- dashboard shouldn't sit on 'runtimepath' at every startup.
	local wrapped_loaded = false
	vim.keymap.set("n", "<leader>ow", function()
		if not wrapped_loaded then
			wrapped_loaded = true
			vim.pack.add({
				{ src = "https://github.com/nvzone/volt" }, -- wrapped.nvim dependency
				{ src = "https://github.com/aikhe/wrapped.nvim" },
			})
		end
		vim.cmd("WrappedNvim")
	end, { desc = "Wrapped dashboard" })

	-- 14. tobira.nvim — vim command learning from usage habits
	require("tobira").setup({})
end)

-- ═══════════════════════════════════════════════════════════════
-- First-use — keymaps that lazily load their plugin on first press
-- ═══════════════════════════════════════════════════════════════
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

-- 13. wrapped.nvim — year-in-review dashboard (:NvimWrapped / :WrappedNvim)
vim.keymap.set("n", "<leader>ow", function()
	lazyload.demand("wrapped", function()
		lazyload.pack_load({
			{ src = "https://github.com/nvzone/volt" },
			{ src = "https://github.com/aikhe/wrapped.nvim" },
		})
	end)
	vim.cmd("WrappedNvim")
end, { desc = "Wrapped dashboard" })
