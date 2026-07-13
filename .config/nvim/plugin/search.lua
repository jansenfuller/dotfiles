require("lazyload").on_vim_enter(function()
	-- ── snacks.nvim (picker) ─────────────────────────────────────
	vim.pack.add({
		{ src = "https://github.com/folke/snacks.nvim" },
	})
	require("snacks").setup({
		picker = { enabled = true },
		explorer = {
			enabled = true,
			file = { filename_only = true },
		},
		words = { enabled = true, debounce = 300 },
		rename = { enabled = true },
	})

	-- ── grug-far.nvim: interactive find & replace ────────────────
	vim.pack.add({
		{ src = "https://github.com/MagicDuck/grug-far.nvim" },
	})
	require("grug-far").setup({})
	vim.keymap.set("n", "<leader>fr", function()
		require("grug-far").open()
	end, { desc = "Find & replace in CWD" })

	-- ── neotest: treesitter-aware test runner ──────────────────
	vim.pack.add({
		{ src = "https://github.com/nvim-neotest/neotest" },
	})
	vim.keymap.set("n", "<leader>tn", function()
		require("neotest").run.run()
	end, { desc = "Run nearest test" })
	vim.keymap.set("n", "<leader>tf", function()
		require("neotest").run.run(vim.fn.expand("%"))
	end, { desc = "Run test file" })
	vim.keymap.set("n", "<leader>ts", function()
		require("neotest").summary.toggle()
	end, { desc = "Test summary" })
	vim.keymap.set("n", "<leader>to", function()
		require("neotest").output.open()
	end, { desc = "Test output" })
end)
