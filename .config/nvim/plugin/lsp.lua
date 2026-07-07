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
    -- Ruby LSP is assumed to be installed manually; no ensure_installed needed.
    handlers = {
      -- Custom config for ruby_lsp (Rails support)
      ruby_lsp = function()
        require("lspconfig").ruby_lsp.setup({
          cmd = { "ruby-lsp" },
          init_options = {
            formatter = "auto",
            -- ruby-lsp-rails is auto-detected from the Gemfile when installed
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
  require("blink.cmp").setup({
    keymap = {
      preset = "default",
      ["<Tab>"] = { "select_next", "fallback" },
      ["<S-Tab>"] = { "select_prev", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
    },
    completion = {
      documentation = { auto_show = false },
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
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    end,
  })

  -- Clean up buffer-local keymaps when LSP detaches
  vim.api.nvim_create_autocmd("LspDetach", {
    callback = function(ev)
      vim.api.nvim_buf_clear_namespace(ev.buf, 0, 0, -1)
    end,
  })
end)
