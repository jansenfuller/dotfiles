-- Bytecode cache for Lua modules — must be the very first thing that runs,
-- before any require() calls, so init.lua/config.lua/plugins all benefit.
vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config")
require("lazyload")

-- Colorscheme: only the active theme loads eagerly (must be applied before
-- VimEnter, not deferred). Alduin/flume/south are only ever used through the
-- <leader>fc picker, so they're added lazily from there (see config.lua).
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
		-- confirm = true: never auto-apply unreviewed updates across all
		-- plugins unattended. Also avoids updating blink.cmp while it (or
		-- another running Neovim instance) still has the old fuzzy-matcher
		-- .dylib open, which is what corrupts its build.
		-- Only record the date if the check actually ran — on this network a
		-- proxy/DNS failure throws, and writing the marker anyway would
		-- silently skip update checks for the rest of the day.
		local ok, err = pcall(vim.pack.update, nil, { confirm = true })
		if ok then
			vim.fn.writefile({ today }, marker)
		else
			vim.notify("Plugin update check failed: " .. tostring(err), vim.log.levels.WARN)
		end
	end
end)
