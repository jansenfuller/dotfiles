local lazyload = require("lazyload")

-- ── LSP Keymaps (buffer-local, set on attach) ───────────────
-- Registered eagerly: attaching autocmds is cheap and must not depend on
-- the lazily loaded LSP stack being up.
local lsp_buf_keymaps = {}

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local maps = {
			{ "n", "gd", vim.lsp.buf.definition, "Go to definition" },
			{ "n", "gD", vim.lsp.buf.declaration, "Go to declaration" },
			{ "n", "gy", vim.lsp.buf.type_definition, "Go to type definition" },
			{ "n", "gr", vim.lsp.buf.references, "References" },
			{ "n", "gI", vim.lsp.buf.implementation, "Implementation" },
			{ "n", "K", function()
				vim.lsp.buf.hover({ border = "rounded" })
			end, "Hover documentation" },
			{ "n", "<leader>ln", vim.lsp.buf.rename, "Rename symbol" },
			{ "n", "<leader>lc", vim.lsp.buf.code_action, "Code action" },
		}
		for _, m in ipairs(maps) do
			vim.keymap.set(m[1], m[2], m[3], { buffer = ev.buf, desc = m[4] })
		end
		lsp_buf_keymaps[ev.buf] = maps
		-- Inlay hints: show inferred types for TypeScript + Rust
		vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
	end,
})

-- Clean up buffer-local keymaps when LSP detaches (tracked in LspAttach)
vim.api.nvim_create_autocmd("LspDetach", {
	callback = function(ev)
		local maps = lsp_buf_keymaps[ev.buf]
		if maps then
			for _, m in ipairs(maps) do
				pcall(vim.keymap.del, m[1], m[2], { buffer = ev.buf })
			end
			lsp_buf_keymaps[ev.buf] = nil
		end
	end,
})

vim.api.nvim_create_autocmd("BufWipeout", {
	callback = function(ev)
		lsp_buf_keymaps[ev.buf] = nil
	end,
})

-- Rebuild the Rust fuzzy matcher when blink.cmp is updated (if it's loaded)
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		if ev.data.spec.name == "blink.cmp" and package.loaded["blink.cmp"] then
			require("blink.cmp").build():pwait()
		end
	end,
})

-- ── LSP/completion stack: loaded on the first code filetype ──
lazyload.on_event("FileType", lazyload.code_filetypes, function()
	lazyload.pack_load({
		{ src = "https://github.com/williamboman/mason.nvim" },
		{ src = "https://github.com/williamboman/mason-lspconfig.nvim" },
		{ src = "https://github.com/neovim/nvim-lspconfig" },
		{ src = "https://github.com/saghen/blink.lib" },
		{ src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
	})

	-- ── Mason: LSP installer UI ─────────────────────────────────
	require("mason").setup()

	-- ── Mason-LSPConfig: bridge mason ↔ lspconfig ───────────────
	-- Servers to auto-install. Already-installed servers are skipped.
	-- automatic_enable = true (default) calls vim.lsp.enable() for installed
	-- servers, which defers actual startup until a matching filetype opens.
	require("mason-lspconfig").setup({
		-- automatic_enable = true by default — servers auto-start on file open
		handlers = {
			-- Custom config for ruby_lsp (Rails support)
			ruby_lsp = function()
				require("lspconfig").ruby_lsp.setup({
					cmd = { "ruby-lsp" },
					init_options = {
						formatter = "auto",
					},
				})
			end,
			-- Default: use lspconfig defaults for all other servers
			function(server_name)
				require("lspconfig")[server_name].setup({})
			end,
		},
	})

	-- ── Blink.cmp: autocompletion ───────────────────────────────
	lazyload.pack_load({
		{ src = "https://github.com/rafamadriz/friendly-snippets" },
	})
	require("blink.cmp").setup({
		keymap = {
			preset = "default",
			["<Tab>"] = { "select_next", "fallback" },
			["<S-Tab>"] = { "select_prev", "fallback" },
			["<CR>"] = { "accept", "fallback" },
		},
		completion = {
			documentation = { auto_show = true, window = { border = "rounded" } },
			menu = {
				border = "rounded",
				draw = {
					columns = {
						{ "kind_icon" },
						{ "label", "custom_detail", gap = 1 },
					},
					components = {
						custom_detail = {
							ellipsis = false,
							width = { max = 40 },
							text = function(ctx)
								local detail = ctx.item.detail or ""
								return detail
							end,
							highlight = "BlinkCmpLabelDetail",
						},
					},
				},
			},
		},
		signature = {
			enabled = true,
			window = { border = "rounded" },
		},
		appearance = {
			kind_icons = {
				Text = "󰉿",
				Method = "󰆧",
				Function = "󰊕",
				Constructor = "",
				Field = "󰜢",
				Variable = "󰀫",
				Class = "󰠱",
				Interface = "",
				Module = "",
				Property = "󰜢",
				Unit = "󰑭",
				Value = "󰎠",
				Enum = "",
				Keyword = "󰌋",
				Snippet = "󰩫",
				Color = "󰏘",
				File = "󰈚",
				Reference = "󰈇",
				Folder = "󰉋",
				EnumMember = "",
				Constant = "󰏿",
				Struct = "󰙅",
				Event = "",
				Operator = "󰆕",
				TypeParameter = "󰊄",
			},
		},
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
		},
		fuzzy = {
			implementation = "prefer_rust",
		},
	})
end)
