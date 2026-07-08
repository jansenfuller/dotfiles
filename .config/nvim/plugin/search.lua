require("lazyload").on_vim_enter(function()
	-- ── snacks.nvim (picker) ─────────────────────────────────────
	vim.pack.add({
		{ src = "https://github.com/folke/snacks.nvim" },
	})
	require("snacks").setup({
		picker = { enabled = true },
		words = { enabled = true, debounce = 300 },
	})

	-- ── grug-far.nvim: interactive find & replace ────────────────
	vim.pack.add({
		{ src = "https://github.com/MagicDuck/grug-far.nvim" },
	})
	require("grug-far").setup({})
	vim.keymap.set("n", "<leader>fr", function()
		require("grug-far").open()
	end, { desc = "Find & replace in CWD" })

	-- ── undotree: visual undo history ──────────────────────────
	vim.pack.add({
		{ src = "https://github.com/mbbill/undotree" },
	})
	vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Toggle undo tree" })
end)
