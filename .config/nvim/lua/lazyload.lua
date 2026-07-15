local M = {}
local queue = {}

vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		-- Step 1: Run sync callbacks first
		for _, entry in ipairs(queue) do
			if entry.sync then
				entry.fn()
			end
		end
		-- Step 2: Then async callbacks (via vim.schedule for FIFO ordering)
		for _, entry in ipairs(queue) do
			if not entry.sync then
				vim.schedule(entry.fn)
			end
		end
		queue = nil
	end,
})

function M.on_vim_enter(fn, opts)
	opts = opts or {}
	if queue then
		-- VimEnter hasn't fired yet — queue it
		table.insert(queue, { fn = fn, sync = opts.sync or false })
	else
		-- VimEnter already fired — execute immediately
		if opts.sync then
			fn()
		else
			vim.schedule(fn)
		end
	end
end

return M
