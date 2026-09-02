-- Deferred / event-driven loading helpers.
--
-- Tiers, in order of how soon they run:
--   1. on_vim_enter — after all startup work, before the first frame paints.
--      Reserve for things the first render needs (statusline, icons, mini).
--   2. on_ui_enter  — after the UI attaches and the first frame is painted.
--      Non-essential UI chrome (bufferline, gitsigns, which-key, ...).
--      Never fires headless, so these also skip `nvim --headless` runs.
--   3. on_event     — one-shot autocmd; first matching event (e.g. FileType).
--      Heavy feature stacks (LSP, treesitter).
--   4. demand       — memoized loader run from keymaps on first use.
--      Pickers, tests, anything only needed when the user asks for it.
local M = {}

-- Startup work queued until VimEnter
local queue = {}

vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		for _, fn in ipairs(queue) do
			-- Each callback is scheduled individually so one plugin block
			-- erroring can't prevent later ones from running.
			vim.schedule(function()
				local ok, err = pcall(fn)
				if not ok then
					vim.notify("lazyload: deferred setup failed: " .. tostring(err), vim.log.levels.ERROR)
				end
			end)
		end
		queue = nil
	end,
})

--- Defer `fn` until after VimEnter (or run it now if VimEnter already fired).
--- @param fn function
function M.on_vim_enter(fn)
	if queue then
		table.insert(queue, fn)
	else
		vim.schedule(fn)
	end
end

-- Run fn once after the UI is attached and the first frame is painted.
function M.on_ui_enter(fn)
	vim.api.nvim_create_autocmd("UIEnter", {
		once = true,
		callback = function()
			vim.schedule(fn)
		end,
	})
end

-- Run fn once the first time `event` fires with a matching pattern.
-- e.g. lazyload.on_event("FileType", lazyload.code_filetypes, load_lsp)
function M.on_event(event, pattern, fn)
	vim.api.nvim_create_autocmd(event, {
		pattern = pattern,
		once = true,
		callback = function()
			fn()
		end,
	})
end

-- Run `loader` exactly once (memoized by name) and return its result.
-- Use from keymaps / autocmds to defer heavy plugin loading to first use.
local loaded = {}
function M.demand(name, loader)
	if loaded[name] == nil then
		loaded[name] = loader()
	end
	return loaded[name]
end

-- Add specs to the packpath and force-load their files so `require` works
-- immediately after. vim.pack's first call of a session triggers an
-- asynchronous lockfile↔disk alignment, and plugins added before that
-- finishes are not loaded yet — `:packadd` (the same primitive vim.pack
-- uses internally) forces the load regardless of that timing.
function M.pack_load(specs)
	vim.pack.add(specs)
	for _, spec in ipairs(specs) do
		local src = type(spec) == 'table' and spec.src or spec
		local name = (type(spec) == 'table' and spec.name) or src:match('[^/]+$'):gsub('%.git$', '')
		pcall(vim.cmd.packadd, name)
	end
end

-- Filetypes that justify loading the LSP/completion stack
M.code_filetypes = {
	"lua",
	"rust",
	"go",
	"elixir",
	"ruby",
	"typescript",
	"typescriptreact",
	"javascript",
	"javascriptreact",
	"python",
	"c",
	"cpp",
	"java",
	"bash",
	"yaml",
	"json",
	"toml",
	"html",
	"css",
	"markdown",
}

return M
