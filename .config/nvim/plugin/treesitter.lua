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

  -- Setup (lightweight — just sets install directory)
  require("nvim-treesitter").setup({
    install_dir = vim.fn.stdpath("data") .. "/site",
  })

  -- Lazily install parsers when a matching filetype is first opened
  local ft_to_parsers = {
    lua          = { "lua", "vim", "vimdoc", "query" },
    go           = { "go" },
    rust         = { "rust" },
    elixir       = { "elixir" },
    markdown     = { "markdown", "markdown_inline" },
    bash         = { "bash" },
    yaml         = { "yaml" },
    json         = { "json" },
    toml         = { "toml" },
    typescript   = { "typescript", "javascript" },
    html         = { "html" },
    css          = { "css" },
  }

  local installed_fts = {}

  vim.api.nvim_create_autocmd("FileType", {
    pattern = vim.tbl_keys(ft_to_parsers),
    callback = function(ev)
      local ft = vim.bo[ev.buf].filetype
      local parsers = ft_to_parsers[ft]
      if parsers and not installed_fts[ft] then
        installed_fts[ft] = true
        -- Async install — doesn't block the UI
        require("nvim-treesitter").install(parsers)
      end
    end,
  })

  -- Enable treesitter highlighting (only for filetypes with parsers)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = {
      "lua", "vim", "vimdoc", "query",
      "markdown", "markdown_inline",
      "bash", "yaml", "json", "toml",
      "go", "rust", "elixir",
      "typescript", "javascript", "typescriptreact", "javascriptreact",
      "html", "css",
    },
    callback = function(ev)
      vim.treesitter.start(ev.buf)
    end,
  })

  -- Enable treesitter-based indentation (experimental)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = {
      "lua", "go", "rust", "elixir", "typescript", "javascript",
      "bash", "yaml", "json", "toml", "html", "css",
    },
    callback = function(ev)
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
  })
end)
