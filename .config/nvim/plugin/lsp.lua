require("lazyload").on_vim_enter(function()
	-- ── Add all LSP/completion plugins ──────────────────────────
	vim.pack.add({
		{ src = "https://github.com/williamboman/mason.nvim" },
		{ src = "https://github.com/williamboman/mason-lspconfig.nvim" },
		{ src = "https://github.com/neovim/nvim-lspconfig" },
		{ src = "https://github.com/saghen/blink.lib" },
		{ src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
	})

	-- Build Rust fuzzy matcher on blink.cmp install/update
	vim.api.nvim_create_autocmd("PackChanged", {
		callback = function(ev)
			if ev.data.spec.name == "blink.cmp" then
				require("blink.cmp").build():pwait()
			end
		end,
	})

	-- ── Mason: LSP installer UI ─────────────────────────────────
	require("mason").setup()

	-- ── Mason-LSPConfig: bridge mason ↔ lspconfig ───────────────
	-- Servers to auto-install. Already-installed servers are skipped.
	-- automatic_enable = true (default) calls vim.lsp.enable() for installed
	-- servers, which defers actual startup until a matching filetype opens.
	require("mason-lspconfig").setup({
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
	vim.pack.add({
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

	-- ── LSP Keymaps (buffer-local, set on attach) ───────────────
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(ev)
			local opts = { buffer = ev.buf }
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
			vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
			vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, opts)
			vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
			vim.keymap.set("n", "gI", vim.lsp.buf.implementation, opts)
			vim.keymap.set("n", "K", function()
				vim.lsp.buf.hover({ border = "rounded" })
			end, opts)
			vim.keymap.set("n", "<leader>ln", vim.lsp.buf.rename, opts)
			vim.keymap.set("n", "<leader>lc", vim.lsp.buf.code_action, opts)
			-- Inlay hints: show inferred types for TypeScript + Rust
			vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
			-- Manually start an LSP server for irregular file extensions
			vim.keymap.set("n", "<leader>lS", function()
				vim.ui.input({ prompt = "LSP server name: " }, function(name)
					if name and name ~= "" then
						local ok, err = pcall(require("lspconfig")[name].setup, { bufnr = ev.buf })
						if not ok then
							vim.notify("Failed to start " .. name .. ": " .. tostring(err), vim.log.levels.ERROR)
						end
					end
				end)
			end, { buffer = ev.buf, desc = "Start LSP manually" })
		end,
	})

	-- Clean up buffer-local keymaps when LSP detaches
	vim.api.nvim_create_autocmd("LspDetach", {
		callback = function(ev)
			vim.api.nvim_buf_clear_namespace(ev.buf, 0, 0, -1)
		end,
	})

	-- ── diactions.nvim: code actions from linter diagnostics ───
	-- Requires none-ls.nvim for full functionality.
	vim.pack.add({
		{ src = "https://github.com/GasparVardanyan/diactions.nvim" },
	})
end)
