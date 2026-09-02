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

	-- foldmethod/foldexpr are WINDOW-local, not buffer-local. So they must be
	-- re-evaluated whenever a window changes which buffer it shows -- otherwise
	-- a window that once displayed a treesitter buffer keeps the treesitter
	-- foldexpr forever, and a later non-parser buffer (.txt/.log/.env) in that
	-- same window gets NO folds at all (foldlevel 0, `za` -> E490).
	-- highlighter.active[buf] is set exactly when vim.treesitter.start()
	-- succeeded for that buffer, and reading it has no side effects.
	local function apply_fold_style(win, buf)
		if not (vim.api.nvim_win_is_valid(win) and vim.api.nvim_buf_is_valid(buf)) then
			return
		end
		if vim.treesitter.highlighter.active[buf] then
			-- AST-based folds: a block's fold range matches its syntax node,
			-- so the header line ("function foo()") folds *that* block rather
			-- than the indent-level fold above it.
			vim.wo[win].foldmethod = "expr"
			vim.wo[win].foldexpr = "v:lua.vim.treesitter.foldexpr()"
		else
			vim.wo[win].foldmethod = "indent"
			vim.wo[win].foldexpr = "0"
		end
	end

	-- Re-apply whenever a buffer is displayed in a window.
	vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
		callback = function(ev)
			apply_fold_style(vim.api.nvim_get_current_win(), ev.buf)
		end,
	})

	vim.api.nvim_create_autocmd("FileType", {
		pattern = vim.tbl_keys(ft_parsers),
		callback = function(ev)
			local ft = vim.bo[ev.buf].filetype
			local parsers = ft_parsers[ft]
			if not parsers then
				return
			end

			local function start_highlighting()
				if not vim.api.nvim_buf_is_valid(ev.buf) then
					return
				end
				-- pcall: the parser can still be absent here if a previous
				-- install failed (installed[ft] is set optimistically), and
				-- an uncaught error would fire on every open of this filetype.
				if not pcall(vim.treesitter.start, ev.buf) then
					return
				end
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					if vim.api.nvim_win_get_buf(win) == ev.buf then
						apply_fold_style(win, ev.buf)
					end
				end
			end

			if not installed[ft] then
				installed[ft] = true
				-- Parser may not be on disk yet — starting highlighting before
				-- install() finishes silently no-ops. Only start once install
				-- (a no-op if already present) actually resolves.
				ensure_treesitter().install(parsers):await(function(err)
					if err then
						-- let a later buffer of this filetype retry
						installed[ft] = nil
						return
					end
					vim.schedule(start_highlighting)
				end)
			else
				start_highlighting()
			end

			-- Indentation
			vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end,
	})
