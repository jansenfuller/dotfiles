vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config")
require("lazyload")

-- Colorscheme: loaded eagerly (must be applied before VimEnter, not deferred)
vim.pack.add({
  { src = "https://github.com/dylanaraps/crayon" },
})
vim.cmd.colorscheme("crayon")
