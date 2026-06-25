require("lazyload").on_vim_enter(function()
  vim.pack.add({
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/nvim-telescope/telescope.nvim" },
  })

  -- ── grug-far.nvim: interactive find & replace ────────────────
  vim.pack.add({
    { src = "https://github.com/MagicDuck/grug-far.nvim" },
  })

  require("grug-far").setup({})
  vim.keymap.set("n", "<leader>fr", function()
    require("grug-far").open()
  end, { desc = "Find & replace in CWD" })

  require("telescope").setup({
    defaults = {
      mappings = {
        i = {
          ["<Esc>"] = "close",       -- one Esc to close
          ["<C-h>"] = "which_key",   -- show telescope keybindings
        },
      },
      layout_strategy = "horizontal",
      layout_config = {
        prompt_position = "top",
      },
      sorting_strategy = "ascending",
      winblend = 0,
    },
    pickers = {
      find_files = {
        hidden = true,            -- show dotfiles
        find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
      },
      live_grep = {
        additional_args = { "--hidden" },
      },
    },
  })
end)
