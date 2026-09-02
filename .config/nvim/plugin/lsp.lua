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

	-- Cargo can get interrupted mid-build (nvim force-quit, crash, or -- the
	-- most common case -- another running Neovim instance still holding the
	-- previous .dylib open, which makes cargo's final copy/rename into
	-- target/release/ fail). That leaves a fully compiled artifact sitting in
	-- target/release/deps/ that never got copied to its final path, while the
	-- version file still matches HEAD -- so blink.cmp thinks it's already
	-- built and just silently falls back to the slower Lua matcher forever.
	-- Detect and repair that exact state automatically.
	local function heal_blink_fuzzy_build()
		local ok_files, files = pcall(require, "blink.cmp.fuzzy.download.files")
		if not ok_files then
			return
		end

		-- already loadable? nothing to repair
		if pcall(require, "blink.cmp.fuzzy.rust") then
			return
		end

		local deps_path = files.lib_folder .. "/deps/" .. files.lib_filename
		if vim.uv.fs_stat(deps_path) and not vim.uv.fs_stat(files.lib_path) then
			local copied = pcall(function()
				assert(vim.uv.fs_copyfile(deps_path, files.lib_path))
			end)
			if copied and pcall(require, "blink.cmp.fuzzy.rust") then
				vim.schedule(function()
					vim.notify(
						"blink.cmp: repaired an interrupted Rust fuzzy-matcher build (restored from cargo's cache)",
						vim.log.levels.WARN
					)
				end)
			end
		end
	end

	-- Repair on every startup, in case a previous build got interrupted.
	heal_blink_fuzzy_build()

	-- Build Rust fuzzy matcher on blink.cmp install/update
	vim.api.nvim_create_autocmd("PackChanged", {
		callback = function(ev)
			if ev.data.spec.name == "blink.cmp" then
				-- Warn if another Neovim is running: it'll hold the old .dylib
				-- open, which is what corrupts the build in the first place.
				local ok_pgrep, pids = pcall(vim.fn.system, { "pgrep", "-x", "nvim" })
				if ok_pgrep and vim.v.shell_error == 0 then
					local count = 0
					for _ in pids:gmatch("%d+") do
						count = count + 1
					end
					if count > 1 then
						vim.notify(
							"blink.cmp: rebuilding fuzzy matcher while other Neovim instances are running "
								.. "can corrupt the build. Close other instances if this fails.",
							vim.log.levels.WARN
						)
					end
				end

				require("blink.cmp").build():pwait()
				heal_blink_fuzzy_build()
			end
		end,
	})

	-- ── Mason: LSP installer UI ─────────────────────────────────
	require("mason").setup()

	-- Custom server config (mason-lspconfig v2 removed `handlers` entirely —
	-- it's silently ignored if passed to .setup(). vim.lsp.config() is the
	-- correct, currently-supported way to override a server's config; it
	-- merges with nvim-lspconfig's defaults before automatic_enable below
	-- calls vim.lsp.enable() for it.
	vim.lsp.config("ruby_lsp", {
		cmd = { "ruby-lsp" },
		init_options = {
			formatter = "auto",
		},
	})

	-- TypeScript (tsgo): nvim-lspconfig's default enables every inlay-hint
	-- category. `variableTypes` is the noisy one -- for an annotated arrow
	-- function it annotates the *variable*, which has no annotation of its
	-- own, and so renders the entire signature as virtual text directly
	-- beside the identical signature you already typed:
	--   const func: (param: string) => string = (param: string) => {...}
	-- TS only suppresses a hint where an explicit annotation exists, and
	-- `func` has none -- so the duplication can't be avoided except by
	-- turning this category off.
	vim.lsp.config("tsgo", {
		settings = {
			typescript = {
				inlayHints = {
					-- off: duplicates types already written in the code
					variableTypes = { enabled = false },
					functionLikeReturnTypes = { enabled = false },
					-- kept: these show information NOT present in the source
					parameterNames = {
						enabled = "literals", -- foo(name: "x") at call sites
						suppressWhenArgumentMatchesName = true,
					},
					parameterTypes = { enabled = true }, -- only fires on un-annotated params
					propertyDeclarationTypes = { enabled = true },
					enumMemberValues = { enabled = true },
				},
			},
		},
	})

	-- ── Mason-LSPConfig: bridge mason ↔ lspconfig ───────────────
	-- lua_ls isn't installed (confirmed via mason/packages/ — that's why Lua
	-- files show no LSP). NOT auto-installing it here: this network has a
	-- corporate SSL-intercepting proxy that already breaks other installs
	-- with SELF_SIGNED_CERT_IN_CHAIN (confirmed in mason.log for json-lsp,
	-- tsgo) — an unattended background install could hang/fail silently.
	-- Install manually so you can see any error directly: `:MasonInstall lua_ls`
	-- automatic_enable = true (default) calls vim.lsp.enable() for installed
	-- servers, which defers actual startup until a matching filetype opens.
	require("mason-lspconfig").setup({
		-- automatic_enable = true by default — servers auto-start on file open
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
		}
	})

	-- ── LSP Keymaps (buffer-local, set on attach) ───────────────
	-- Neovim 0.12 already ships these LSP defaults, so they are NOT redefined
	-- here:  grn rename · gra code action · grr references · gri implementation
	--        grt type definition · grx codelens · gO document symbol · K hover
	-- Notably `gr` must NOT be mapped — it's a prefix of all the gr* defaults,
	-- so mapping it makes every one of them stall for 'timeoutlen' (300ms).
	-- Only genuinely-missing bindings are defined below.
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(ev)
			local opts = { buffer = ev.buf }
			-- Vim's built-in `gd`/`gD` are local/global *declaration* search,
			-- not LSP — overriding them with LSP equivalents is a real upgrade.
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
			vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

			-- <leader>l* (LSP group, see plugin/ui.lua which-key group) —
			-- buffer-local so they don't silently misfire in buffers with no
			-- LSP client attached. These were dropped when they were moved
			-- here from lua/config.lua; restored below.
			vim.keymap.set(
				"n",
				"<leader>ld",
				vim.lsp.buf.definition,
				vim.tbl_extend("force", opts, { desc = "Go to definition" })
			)
			vim.keymap.set(
				"n",
				"<leader>li",
				vim.lsp.buf.implementation,
				vim.tbl_extend("force", opts, { desc = "Go to implementation" })
			)
			vim.keymap.set(
				"n",
				"<leader>lk",
				vim.lsp.buf.type_definition,
				vim.tbl_extend("force", opts, { desc = "Peek type definition" })
			)
			vim.keymap.set(
				"n",
				"<leader>lr",
				vim.lsp.buf.references,
				vim.tbl_extend("force", opts, { desc = "Go to references" })
			)

			-- Inlay hints: only for languages where they add information the
			-- source doesn't already carry. Previously enabled for *every*
			-- attached server (rubocop, yamlls, bash-language-server, ...),
			-- which is meaningless for most of them and is the source of the
			-- recurring "inlay_hint.lua: Invalid 'col': out of range"
			-- decoration-provider errors in ~/.local/state/nvim/nvim.log.
			local inlay_hint_filetypes = {
				typescript = true,
				typescriptreact = true,
				javascript = true,
				javascriptreact = true,
				rust = true,
			}
			if inlay_hint_filetypes[vim.bo[ev.buf].filetype] then
				vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
			end
		end,
	})

	-- ── diactions.nvim: code actions from linter diagnostics ───
	-- Requires none-ls.nvim for full functionality.
	vim.pack.add({
		{ src = "https://github.com/GasparVardanyan/diactions.nvim" },
	})
end)
