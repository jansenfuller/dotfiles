vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  { "wakatime/vim-wakatime", lazy = false },

  {
    "olimorris/codecompanion.nvim",
    lazy = false,
    version = "^18.0.0",
    opts = {
      interactions = {
        chat = {
          adapter = {
            name = "ollama",
            model = "qwen3:1.7b"
          },
        },
        inline = {
          adapter = {
            name = "ollama",
            model = "qwen3:1.7b"
          }
        }
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "nvchad.options"
require "nvchad.autocmds"

vim.schedule(function()
  require "nvchad.mappings"

  -- add yours here

  local map = vim.keymap.set

  map("n", ";", ":", { desc = "CMD enter command mode" })
  map("i", "jk", "<ESC>")
end)
