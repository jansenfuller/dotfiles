local lazyload = require("lazyload")

-- ── neotest — test runner for Rust and Ruby (lazy: first <leader>t press) ──
local function ensure_neotest()
	lazyload.demand("neotest", function()
		lazyload.pack_load({
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
	end)
end

-- Keymaps
vim.keymap.set("n", "<leader>tr", function()
	ensure_neotest()
	require("neotest").run.run()
end, { desc = "Run nearest test" })
vim.keymap.set("n", "<leader>tn", function()
	ensure_neotest()
	require("neotest").run.run()
end, { desc = "Run nearest test" })
vim.keymap.set("n", "<leader>tf", function()
	ensure_neotest()
	require("neotest").run.run(vim.fn.expand("%"))
end, { desc = "Run test file" })
vim.keymap.set("n", "<leader>ts", function()
	ensure_neotest()
	require("neotest").summary.toggle()
end, { desc = "Test summary" })
vim.keymap.set("n", "<leader>to", function()
	ensure_neotest()
	require("neotest").output.open({ enter = true })
end, { desc = "Test output" })
