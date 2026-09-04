local lazyload = require("lazyload")

-- Auto-update parsers when the plugin itself is updated (only if loaded)
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		if ev.data.spec.name == "nvim-treesitter" and package.loaded["nvim-treesitter"] then
			vim.cmd("TSUpdate")
		end
	end,
})

-- Single source of truth: filetype → parsers to install & highlight
local ft_parsers = {
	lua = { "lua" },
	go = { "go" },
	rust = { "rust" },
	elixir = { "elixir" },
	python = { "python" },
	c = { "c" },
	cpp = { "cpp" },
	java = { "java" },
	markdown = { "markdown", "markdown_inline" },
	bash = { "bash" },
	yaml = { "yaml" },
	json = { "json" },
	toml = { "toml" },
	typescript = { "typescript", "javascript" },
	javascript = { "javascript" },
	html = { "html" },
	css = { "css" },
	ruby = { "ruby" },
	eruby = { "embedded_template" },
	typescriptreact = { "tsx", "typescript", "javascript" },
	javascriptreact = { "tsx", "javascript" },
}
local installed = {}

-- Load the plugin itself on first use (inside the FileType autocmd below)
local function ensure_treesitter()
	return lazyload.demand("treesitter", function()
		lazyload.pack_load({
			{ src = "https://github.com/nvim-treesitter/nvim-treesitter", branch = "main" },
		})
		require("nvim-treesitter").setup({
			install_dir = vim.fn.stdpath("data") .. "/site",
		})
		return require("nvim-treesitter")
	end)
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = vim.tbl_keys(ft_parsers),
	callback = function(ev)
		local ft = vim.bo[ev.buf].filetype
		local parsers = ft_parsers[ft]
		if not parsers then
			return
		end
		local ts = ensure_treesitter() -- loads the plugin on the first match
		if not installed[ft] then
			installed[ft] = true -- only request an install once per filetype
			ts.install(parsers)
		end
		-- Highlighting: parsers compile asynchronously, so keep retrying
		-- until the buffer is actually highlighted (first-open only, ~2 min cap)
		local attempts = 0
		local function start_highlight()
			if not vim.api.nvim_buf_is_valid(ev.buf) then
				return
			end
			local ok, started = pcall(vim.treesitter.start, ev.buf)
			if ok and started then
				return
			end
			attempts = attempts + 1
			if attempts < 120 then
				vim.defer_fn(start_highlight, 1000)
			end
		end
		start_highlight()
		-- Indentation
		vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})
