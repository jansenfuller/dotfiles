-- Project-wide diagnostics
-- Collects diagnostics from all LSP-managed files and shows in a quickfix list.
-- For servers that support workspace/diagnostic (gopls, rust-analyzer, ts_ls),
-- it triggers a full project scan. For others, it pulls diagnostics from all
-- loaded buffers.
-- Keymaps:
--   <leader>lr  — Refresh diagnostics for all files (manual)
--   <leader>ld  — Open all diagnostics in quickfix list

local M = {}
local is_refreshing = false

--- @return vim.lsp.Client[]
local function get_workspace_clients()
  local clients = {}
  for _, client in ipairs(vim.lsp.get_clients() or {}) do
    local ok = pcall(client.supports_method, client, "workspace/diagnostic")
    if ok then
      table.insert(clients, client)
    end
  end
  return clients
end

--- @return vim.lsp.Client[]
local function get_all_clients()
  return vim.lsp.get_clients() or {}
end

--- Trigger diagnostic pull for loaded buffers for a specific client
--- @param client vim.lsp.Client
local function pull_buffer_diagnostics(client)
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].modified then
      -- This triggers textDocument/diagnostic for the buffer on the server
      pcall(vim.lsp.diagnostic._enable, bufnr, client.id)
    end
  end
end

--- Refresh all project diagnostics.
--- Triggers workspace/diagnostic on servers that support it (gopls, rust-analyzer, ts_ls),
--- and pulls diagnostics for loaded buffers on all other LSP servers.
function M.refresh()
  local ws_clients = get_workspace_clients()
  local all_clients = get_all_clients()

  if #all_clients == 0 then
    vim.notify("No LSP servers running", vim.log.levels.WARN)
    return
  end

  local ws_count = 0
  for _, client in ipairs(ws_clients) do
    pcall(vim.lsp.diagnostic._workspace_diagnostics, { client_id = client.id })
    ws_count = ws_count + 1
  end

  -- For clients that don't support workspace/diagnostic, pull diagnostics
  -- on all loaded buffers instead
  local pull_count = 0
  for _, client in ipairs(all_clients) do
    if not client.supports_method("workspace/diagnostic") then
      pull_buffer_diagnostics(client)
      pull_count = pull_count + 1
    end
  end

  local parts = {}
  if ws_count > 0 then
    table.insert(parts, ws_count .. " workspace pull(s)")
  end
  if pull_count > 0 then
    table.insert(parts, pull_count .. " buffer pull(s)")
  end
  vim.notify(
    "Project diagnostics refreshing (" .. table.concat(parts, ", ") .. ")",
    vim.log.levels.INFO
  )
end

--- Open all project diagnostics in the quickfix list.
--- Shows diagnostics from ALL files the LSP has checked (open + any with cached results).
function M.open()
  -- Collect diagnostics from all known buffers
  local diagnostics = vim.diagnostic.get(nil)
  if #diagnostics == 0 then
    -- maybe no cached diagnostics yet - try explicit fallback per buffer
    local bufs = vim.api.nvim_list_bufs()
    for _, bufnr in ipairs(bufs) do
      if vim.api.nvim_buf_is_loaded(bufnr) or vim.bo[bufnr].buflisted then
        local buf_diags = vim.diagnostic.get(bufnr)
        for _, d in ipairs(buf_diags) do
          table.insert(diagnostics, d)
        end
      end
    end
  end

  if #diagnostics == 0 then
    vim.notify("No diagnostics found yet. Press <leader>lr to refresh.", vim.log.levels.WARN)
    return
  end

  vim.diagnostic.setqflist({ open = true, title = "Project Diagnostics" })
  vim.notify("Showing " .. #diagnostics .. " diagnostic(s) in quickfix list", vim.log.levels.INFO)
end

--- Auto-run on VimEnter for the current project (once)
function M.auto_refresh()
  if vim.fn.argc() > 0 or vim.bo.buftype ~= "" then
    return
  end
  vim.defer_fn(function()
    if #get_all_clients() > 0 then
      M.refresh()
    end
  end, 3000)
end

return M
