local lazyload = require("lazyload")

-- ── snacks.nvim (picker/explorer/terminal) — lazy global ────
-- `Snacks.*` is referenced from many keymaps in config.lua and ui.lua.
-- This proxy installs a Snacks global that loads the plugin on first
-- access, so the whole picker stack is only loaded when the user
-- actually opens a picker.
local function snacks_module()
	return lazyload.demand("snacks", function()
		lazyload.pack_load({
			{ src = "https://github.com/folke/snacks.nvim" },
		})
		require("snacks").setup({
			picker = {
				enabled = true,
				layout = { border = "rounded" },
			},
			explorer = { enabled = true, hidden = true },
			words = { enabled = false },
			rename = { enabled = true },
		})
		return require("snacks")
	end)
end

_G.Snacks = setmetatable({}, {
	__index = function(_, key)
		return snacks_module()[key]
	end,
})

-- ── grug-far.nvim: interactive find & replace (lazy: first <leader>fr) ──
local function open_grug_far()
	lazyload.demand("grug-far", function()
		lazyload.pack_load({
			{ src = "https://github.com/MagicDuck/grug-far.nvim" },
		})
		require("grug-far").setup({})
	end)
	require("grug-far").open()
end
vim.keymap.set("n", "<leader>fr", open_grug_far, { desc = "Find & replace in CWD" })
