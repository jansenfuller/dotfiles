require("lazyload").on_vim_enter(function()
	-- ═══════════════════════════════════════════════════════════════
	-- 1. nvim-surround — ys / cs / ds for tags, brackets, quotes
	-- ═══════════════════════════════════════════════════════════════
	vim.pack.add({
		{ src = "https://github.com/kylechui/nvim-surround" },
	})
	require("nvim-surround").setup({})

	-- ═══════════════════════════════════════════════════════════════
	-- 2. neotest — test runner for Rust and Ruby
	-- ═══════════════════════════════════════════════════════════════
	vim.pack.add({
		{ src = "https://github.com/nvim-neotest/neotest" },
		{ src = "https://github.com/nvim-lua/plenary.nvim" },
		{ src = "https://github.com/nvim-neotest/nvim-nio" },
		{ src = "https://github.com/rouge8/neotest-rust" },
		{ src = "https://github.com/olimorris/neotest-rspec" },
	})

	require("neotest").setup({
		adapters = {
			require("neotest-rust"),
			require("neotest-rspec"),
		},
		status = { virtual_text = true },
		output = { open_on_run = true },
	})

	-- Keymaps
	vim.keymap.set("n", "<leader>tr", function()
		require("neotest").run.run()
	end, { desc = "Run nearest test" })
	vim.keymap.set("n", "<leader>tf", function()
		require("neotest").run.run(vim.fn.expand("%"))
	end, { desc = "Run test file" })
	vim.keymap.set("n", "<leader>ts", function()
		require("neotest").summary.toggle()
	end, { desc = "Test summary" })
	vim.keymap.set("n", "<leader>to", function()
		require("neotest").output.open({ enter = true })
	end, { desc = "Test output" })
end)
