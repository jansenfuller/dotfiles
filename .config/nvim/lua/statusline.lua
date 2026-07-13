local M = {}
local cache = {}  -- strong refs: never GC'd mid-session

-- Update cache only when LSP state could change
local group = vim.api.nvim_create_augroup("StatuslineLSP", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "LspAttach", "LspDetach" }, {
  group = group,
  callback = function(ev)
    local clients = vim.lsp.get_clients({ bufnr = ev.buf })
    local name
    for _, c in ipairs(clients) do
      if c.name ~= "copilot" and c.name ~= "null-ls" then name = c.name; break end
    end
    if not name and #clients > 0 then name = clients[1].name end
    if name then
      name = name:gsub("^typescript%-language%-server$", "ts")
        :gsub("^ruby%-lsp$", "ruby"):gsub("^rust%-analyzer$", "ra")
        :gsub("^bash-language-server$", "bash"):gsub("^yaml-language-server$", "yaml")
        :gsub("^elixirls$", "elixir"):gsub("^lua-language-server$", "lua")
        :gsub("^vtsls$", "ts")
    end
    cache[ev.buf] = name  -- nil = no LSP
  end,
})

vim.api.nvim_create_autocmd("BufWipeout", {
  group = group,
  callback = function(ev) cache[ev.buf] = nil end,
})

function M.active()
  local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
  local git = MiniStatusline.section_git({ trunc_width = 75 })
  local diagnostics = MiniStatusline.section_diagnostics({
    trunc_width = 75, signs = { ERROR = "E", WARN = "W", INFO = "I", HINT = "I" },
  })

  -- Path relative to project root
  local filename = vim.fn.expand("%:p")
  if filename ~= "" then
    local root = vim.fs.root(0, { ".git" })
    filename = root and filename:sub(#root + 2) or vim.fn.expand("%:t")
  else
    filename = "[No Name]"
  end

  -- Git diff stats from gitsigns (buffer-local, already cached by gitsigns)
  local diff = ""
  local d = vim.b.gitsigns_status_dict
  if d then
    local parts = {}
    if d.added and d.added > 0 then table.insert(parts, "+" .. d.added) end
    if d.changed and d.changed > 0 then table.insert(parts, "~" .. d.changed) end
    if d.removed and d.removed > 0 then table.insert(parts, "-" .. d.removed) end
    if #parts > 0 then diff = " " .. table.concat(parts, " ") end
  end

  -- LSP name from cache (always present)
  local lsp = cache[vim.api.nvim_get_current_buf()] or "No LSP"
  local enc = vim.bo.fenc ~= "" and vim.bo.fenc:upper() or nil
  local ff = vim.bo.ff == "unix" and "LF" or vim.bo.ff == "dos" and "CRLF" or ""

  local groups = {
    { hl = mode_hl, strings = { mode } },
    { hl = "MiniStatuslineFilename", strings = { git .. diff, filename } },
    "%=",
    { hl = "MiniStatuslineModeNormal", strings = { lsp } },
    { hl = "MiniStatuslineFileinfo", strings = { diagnostics } },
  }
  if enc then table.insert(groups, { hl = "MiniStatuslineFileinfo", strings = { enc } }) end
  if ff ~= "" then table.insert(groups, { hl = "MiniStatuslineFileinfo", strings = { ff } }) end
  table.insert(groups, { hl = "MiniStatuslineFileinfo", strings = { MiniStatusline.section_fileinfo({ trunc_width = 120 }) } })

  return MiniStatusline.combine_groups(groups)
end

return M
