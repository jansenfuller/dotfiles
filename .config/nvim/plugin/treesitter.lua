require("lazyload").on_vim_enter(function()
	-- Auto-update parsers when the plugin itself is updated
	vim.api.nvim_create_autocmd("PackChanged", {
		callback = function(ev)
			if ev.data.spec.name == "nvim-treesitter" then
				vim.cmd("TSUpdate")
			end
		end,
	})

	vim.pack.add({
		{ src = "https://github.com/nvim-treesitter/nvim-treesitter", branch = "main" },
	})

	require("nvim-treesitter").setup({
		install_dir = vim.fn.stdpath("data") .. "/site",
	})

	-- Single source of truth: filetype → parsers to install & highlight
	local ft_parsers = {
		lua = { "lua" }, go = { "go" }, rust = { "rust" },
		elixir = { "elixir" }, markdown = { "markdown", "markdown_inline" },
		bash = { "bash" }, yaml = { "yaml" }, json = { "json" }, toml = { "toml" },
		typescript = { "typescript", "javascript" }, html = { "html" }, css = { "css" },
	}
	-- Filetypes that get derived parsers (e.g. typescriptreact → typescript)
	local derived = { typescriptreact = "typescript", javascriptreact = "javascript" }

	local installed = {}

	vim.api.nvim_create_autocmd("FileType", {
		pattern = vim.tbl_keys(vim.tbl_extend("force", ft_parsers, derived)),
		callback = function(ev)
			local ft = vim.bo[ev.buf].filetype
			local parsers = ft_parsers[ft] or (derived[ft] and ft_parsers[derived[ft]])
			if parsers and not installed[ft] then
				installed[ft] = true
				require("nvim-treesitter").install(parsers)
			end
			-- Highlighting
			if parsers then
				vim.treesitter.start(ev.buf)
			end
			-- Indentation
			if ft_parsers[ft] then
				vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end
		end,
	})
end)
