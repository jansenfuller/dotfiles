require("lazyload").on_vim_enter(function()
	-- ═══════════════════════════════════════════════════════════════
	-- neotest — test runner for Rust and Ruby
	--
	-- Lazily loaded: neotest pulls in 4 dependencies (plenary, nvim-nio and
	-- two adapters) that are useless until you actually run a test, so none
	-- of them touch 'runtimepath' at startup. The first <leader>t* press
	-- adds + configures them, then performs the action.
	-- ═══════════════════════════════════════════════════════════════
	local loaded = false
	local function neotest()
		if not loaded then
			loaded = true
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
		end
		return require("neotest")
	end

	-- Keymaps
	vim.keymap.set("n", "<leader>tr", function()
		neotest().run.run()
	end, { desc = "Run nearest test" })
	vim.keymap.set("n", "<leader>tf", function()
		neotest().run.run(vim.fn.expand("%"))
	end, { desc = "Run test file" })
	vim.keymap.set("n", "<leader>ts", function()
		neotest().summary.toggle()
	end, { desc = "Test summary" })
	vim.keymap.set("n", "<leader>to", function()
		neotest().output.open({ enter = true })
	end, { desc = "Test output" })
end)
