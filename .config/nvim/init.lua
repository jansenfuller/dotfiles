vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config")
require("lazyload")

-- Colorscheme: loaded eagerly (must be applied before VimEnter, not deferred)
vim.pack.add({
	{ src = "https://github.com/AlexvZyl/nordic.nvim" },
})
-- Apply on startup; on first run the package isn't installed yet, so retry
-- once the scheduled plugin update installs it (PackChanged event).
if not pcall(vim.cmd.colorscheme, "nordic") then
	vim.api.nvim_create_autocmd("PackChanged", {
		callback = function(ev)
			if ev.data.spec.name == "nordic.nvim" then
				pcall(vim.cmd.colorscheme, "nordic")
			end
		end,
	})
end

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
