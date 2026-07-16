vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config")
require("lazyload")

-- Colorscheme: loaded eagerly (must be applied before VimEnter, not deferred)
vim.pack.add({
  { src = "https://github.com/rebelot/kanagawa.nvim" },
})
vim.cmd.colorscheme("kanagawa")

-- Check for plugin updates once per day
vim.schedule(function()
	local marker = vim.fn.stdpath("data") .. "/last_plugin_update"
	local today = os.date("%Y-%m-%d")
	local last = ""
	pcall(function()
		last = vim.fn.readfile(marker)[1] or ""
	end)
	if last ~= today then
		vim.notify("Checking plugin updates...", vim.log.levels.INFO)
		vim.pack.update(nil, { confirm = false })
		vim.fn.writefile({ today }, marker)
	end
end)
