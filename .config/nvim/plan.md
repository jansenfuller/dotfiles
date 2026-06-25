# Neovim Configuration Plan

> Built from scratch using `vim.pack` (Neovim ≥ 0.12.0 built-in package manager).  
> Follows patterns from [fredrikaverpil.github.io/blog/2026/04/15/from-lazy.nvim-to-vim.pack](https://fredrikaverpil.github.io/blog/2026/04/15/from-lazy.nvim-to-vim.pack/).

---

## Prerequisites

| Requirement | Minimum | Notes |
|---|---|---|
| Neovim | 0.12.0+ | Required for `vim.pack` API |
| Git | 2.19.0+ | Required for partial clones |
| Nerd Font | — | Recommended for lualine/bufferline/toggleterm icons |
| ripgrep | — | Required for telescope `live_grep` |
| Node.js | — | Required for `typescript-language-server` |
| Elixir + mix | — | Required for `elixir-ls` |
| Go | — | Required for `gopls` |
| Rust toolchain | — | Required for `rust-analyzer` + blink.cmp Rust fuzzy matcher |

---

## Architecture

```
Neovim Startup Sequence
│
├─ Step 7b: init.lua runs
│   ├── vim.g.mapleader = " "
│   ├── require("config")                    → options + keymaps + diagnostics
│   ├── vim.pack.add({ crayon })             → adds colorscheme to runtime path (eager)
│   ├── vim.cmd.colorscheme("crayon")        → applies colorscheme immediately
│   └── require("lazyload")                  → creates VimEnter autocmd
│
├─ Step 11: plugin/*.lua files load alphabetically
│   ├── plugin/lsp.lua                       → registers deferred callback
│   ├── plugin/telescope.lua                 → registers deferred callback
│   ├── plugin/treesitter.lua                → registers deferred callback
│   └── plugin/ui.lua                        → registers deferred callback
│       (Each file calls lazyload.on_vim_enter(fn) — does NOT run expensive work yet)
│
├─ Step 18: VimEnter fires
│   └── lazyload.lua drains the queue:
│       ├── Sync callbacks first (none in our setup — simplified)
│       └── Async callbacks via vim.schedule (FIFO order):
│           1. plugin/lsp.lua        → mason → lspconfig → blink.cmp
│           2. plugin/telescope.lua  → telescope + plenary
│           3. plugin/treesitter.lua → nvim-treesitter
│           4. plugin/ui.lua         → web-devicons → gitsigns → lualine → bufferline → toggleterm → nvim-tree
│
└─ Later: PackChanged autocmd fires on plugin install/update
    ├── nvim-treesitter   → TSUpdate (recompile parsers)
    └── blink.cmp         → build() (compile Rust fuzzy matcher)
```

---

## Directory Structure

```
~/.config/nvim/
├── init.lua                          # Entry point (~12 lines)
├── nvim-pack-lock.json               # Auto-generated lockfile (git-track this)
├── plan.md                           # This file
├── lua/
│   ├── config.lua                    # vim.opt + diagnostics + keymaps (~50 lines)
│   └── lazyload.lua                  # VimEnter deferral helper (~35 lines)
└── plugin/
    ├── lsp.lua                       # mason + lspconfig + blink.cmp (~60 lines)
    ├── telescope.lua                 # telescope + plenary (~25 lines)
    ├── treesitter.lua                # nvim-treesitter (~25 lines)
    └── ui.lua                        # icons + gitsigns + lualine + bufferline + toggleterm + nvim-tree (~75 lines)
```

**7 files total.**

---

## File 1: `init.lua` (~12 lines)

**Purpose:** Bootstrap entry point. Loads config, lazyload infrastructure, and applies the colorscheme eagerly (before UI renders).

**Contents:**
```lua
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config")
require("lazyload")

-- Colorscheme: loaded eagerly (must be applied before VimEnter, not deferred)
vim.pack.add({
  { src = "https://github.com/dylanaraps/crayon" },
})
vim.cmd.colorscheme("crayon")
```

| Concern | Detail |
|---|---|
| `mapleader` | Space — must be set before any mappings are defined |
| `config` | Sources `lua/config.lua` (options, diagnostics, keymaps) |
| `lazyload` | Sources `lua/lazyload.lua` (creates VimEnter autocmd) |
| Colorscheme | Eager — crayon is a dark 16-color vimscript theme. `vim.pack.add()` in init.lua defaults to `load=false` (doesn't source plugin scripts), but `colors/` files are path-based and available immediately. |

---

## File 2: `lua/config.lua` (~50 lines)

**Purpose:** All `vim.opt` editor settings, diagnostic configuration, and keybindings. Runs eagerly in init.lua.

### Options Section

```lua
-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Tabs & indentation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- UI
vim.opt.termguicolors = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 8

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- Splits
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Performance
vim.opt.updatetime = 750
vim.opt.timeoutlen = 1000
vim.opt.ttimeoutlen = 10
```

### Diagnostics Section

```lua
vim.diagnostic.config({
  virtual_text = false,       -- NO inline text that runs off screen
  signs = true,               -- Gutter signs stay (●/►/■)
  underline = true,           -- Squiggly underline stays
  update_in_insert = false,   -- Don't update while typing
  severity_sort = true,       -- Errors before warnings
  float = {
    border = "rounded",
    source = true,
    header = "",
  },
})

-- Show diagnostic float on hover after 750ms idle
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, {
      scope = "cursor",
      border = "rounded",
      source = true,
      focusable = false,
      prefix = "● ",
    })
  end,
})
```

### Keymaps Section

```lua
-- Telescope
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Help tags" })

-- File explorer
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Down window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Up window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Right window" })

-- Clear search highlight
vim.keymap.set("n", "<leader>h", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
```

**Note:** LSP keymaps (`gd`, `gr`, `K`, `[d`, `]d`) are defined in `plugin/lsp.lua` via `LspAttach` autocmd, because they need the buffer-local context. Git hunk keymaps (`[h`, `]h`) are defined in `plugin/ui.lua` via gitsigns setup.

---

## File 3: `lua/lazyload.lua` (~35 lines)

**Purpose:** Deferred loading infrastructure. All plugin files register callbacks that execute after `VimEnter`, keeping startup snappy.

```lua
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
```

| Concept | Detail |
|---|---|
| `queue` | Table of `{ fn, sync }` entries |
| Sync first | Sync callbacks run inline during VimEnter (for plugins that must be ready before UI draws) |
| Async second | Async callbacks dispatched via `vim.schedule` — runs in FIFO insertion order |
| `queue = nil` | Allows garbage collection after drain |
| Safe re-entry | If `on_vim_enter` is called after VimEnter fired, executes immediately |

**Our setup:** All plugins use async (default). No sync callbacks needed since web-devicons, lualine, and bufferline all load in the same callback in `plugin/ui.lua` with correct internal ordering.

---

## File 4: `plugin/treesitter.lua` (~25 lines)

**Purpose:** Syntax highlighting via tree-sitter. Uses `PackChanged` autocmd to auto-update parsers on plugin install/update.

**Source:** `https://github.com/nvim-treesitter/nvim-treesitter`

```lua
require("lazyload").on_vim_enter(function()
  -- Auto-update parsers on install/update
  vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(ev)
      if ev.data.spec.name == "nvim-treesitter" then
        vim.cmd("TSUpdate")
      end
    end,
  })

  vim.pack.add({
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", branch = "main" },
  })

  -- Setup nvim-treesitter (new API: only accepts install_dir)
  require("nvim-treesitter").setup({
    install_dir = vim.fn.stdpath("data") .. "/site",
  })

  -- Install parsers (async, wait up to 5 min for completion)
  require("nvim-treesitter").install({
    "lua",
    "vim",
    "vimdoc",
    "query",
    "markdown",
    "markdown_inline",
    "bash",
    "yaml",
    "json",
    "toml",
    "go",
    "rust",
    "elixir",
    "typescript",
    "javascript",
    "html",
    "css",
  }):wait(300000)

  -- Enable treesitter highlighting globally via Neovim built-in
  vim.api.nvim_create_autocmd("FileType", {
    callback = function(ev)
      pcall(vim.treesitter.start, ev.buf)
    end,
  })

  -- Enable treesitter-based indentation (experimental)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = {
      "lua", "go", "rust", "elixir", "typescript", "javascript",
      "bash", "yaml", "json", "toml", "html", "css",
    },
    callback = function(ev)
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
  })
end)
```

| Setting | Detail |
|---|---|
| `branch = "main"` | Follow main branch (treesitter was fully rewritten) |
| `install()` | Replaces old `ensure_installed` — async, use `:wait()` for sync bootstrapping |
| `vim.treesitter.start()` | Replaces old `highlight.enable` — built-in Neovim, enabled per FileType |
| `indentexpr()` | Replaces old `indent.enable` — experimental, enabled per FileType |
| `PackChanged` → `TSUpdate` | Recompiles parsers when nvim-treesitter itself updates |

---

## File 5: `plugin/lsp.lua` (~60 lines)

**Purpose:** LSP server management (install + configure) and autocompletion. Combines 5 plugins:

| Plugin | Source |
|---|---|
| mason.nvim | `https://github.com/williamboman/mason.nvim` |
| mason-lspconfig.nvim | `https://github.com/williamboman/mason-lspconfig.nvim` |
| nvim-lspconfig | `https://github.com/neovim/nvim-lspconfig` |
| blink.cmp | `https://github.com/saghen/blink.cmp` |
| blink.lib | `https://github.com/saghen/blink.lib` |

```lua
require("lazyload").on_vim_enter(function()
  -- ── Add all LSP/completion plugins ──────────────────────────
  vim.pack.add({
    { src = "https://github.com/williamboman/mason.nvim" },
    { src = "https://github.com/williamboman/mason-lspconfig.nvim" },
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/saghen/blink.lib" },
    { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
  })

  -- Build Rust fuzzy matcher on blink.cmp install/update
  vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(ev)
      if ev.data.spec.name == "blink.cmp" then
        require("blink.cmp").build():pwait()
      end
    end,
  })

  -- ── Mason: LSP installer UI ─────────────────────────────────
  require("mason").setup()

  -- ── Mason-LSPConfig: bridge mason ↔ lspconfig ───────────────
  require("mason-lspconfig").setup({
    ensure_installed = {
      "ts_ls",           -- TypeScript/JavaScript
      "elixirls",        -- Elixir
      "rust_analyzer",   -- Rust
      "bashls",          -- Bash/Shell
      "yamlls",          -- YAML
      "gopls",           -- Go
    },
  })

  -- Automatic enable via vim.lsp.enable() is on by default (no manual setup_handlers needed)

  -- ── Blink.cmp: autocompletion ───────────────────────────────
  require("blink.cmp").setup({
    keymap = { preset = "super-tab" },
    completion = {
      documentation = { auto_show = false },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    fuzzy = {
      implementation = "prefer_rust",  -- Rust if built, Lua fallback
    },
  })

  -- ── LSP Keymaps (buffer-local, set on attach) ───────────────
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
      local opts = { buffer = ev.buf }
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
      vim.keymap.set("n", "gI", vim.lsp.buf.implementation, opts)
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    end,
  })
end)
```

### LSP Server Mapping

| Language | Mason Package | lspconfig Name (used in ensure_installed) | Filetypes |
|---|---|---|---|
| TypeScript | `typescript-language-server` | `ts_ls` | `typescript`, `javascript`, `typescriptreact`, `javascriptreact` |
| Elixir | `elixir-ls` | `elixirls` | `elixir`, `eelixir`, `heex`, `surface` |
| Rust | `rust-analyzer` | `rust_analyzer` | `rust` |
| Bash | `bash-language-server` | `bashls` | `sh`, `bash`, `zsh` |
| YAML | `yaml-language-server` | `yamlls` | `yaml`, `yml` |
| Go | `gopls` | `gopls` | `go`, `gomod`, `gowork` |

> `ensure_installed` uses **lspconfig server names** (not mason package names).
> mason-lspconfig automatically translates them to mason package names internally.
> Installed servers are auto-enabled via `vim.lsp.enable()` — no `setup_handlers` needed.

### Blink.cmp Sources

| Source | Built-in? | Description |
|---|---|---|
| `lsp` | ✅ | LSP completions from configured servers |
| `path` | ✅ | File path completions |
| `snippets` | ✅ | Snippet completions (native `vim.snippet`) |
| `buffer` | ✅ | Words from open buffers |

> No external source plugins needed — all four are built into blink.cmp.

### Keybindings (LSP)

| Key | Action |
|---|---|
| `gd` | Go to definition |
| `gr` | Go to references |
| `K` | Hover documentation |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action (quick fix) |
| `gI` | Go to implementation |
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |

---

## File 6: `plugin/telescope.lua` (~25 lines)

**Purpose:** Fuzzy finder for files, grep, buffers, and help.

| Plugin | Source |
|---|---|
| plenary.nvim | `https://github.com/nvim-lua/plenary.nvim` |
| telescope.nvim | `https://github.com/nvim-telescope/telescope.nvim` |

```lua
require("lazyload").on_vim_enter(function()
  vim.pack.add({
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/nvim-telescope/telescope.nvim" },
  })

  require("telescope").setup({
    defaults = {
      mappings = {
        i = {
          ["<C-h>"] = "which_key",  -- hide default mappings help popup
        },
      },
      layout_strategy = "horizontal",
      layout_config = {
        prompt_position = "top",
      },
      sorting_strategy = "ascending",
      winblend = 0,
    },
    pickers = {
      find_files = {
        hidden = true,            -- show dotfiles
        find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
      },
      live_grep = {
        additional_args = { "--hidden" },
      },
    },
  })
end)
```

| Setting | Detail |
|---|---|
| `hidden = true` | Show dotfiles in find_files |
| `rg --files --hidden` | Uses ripgrep with hidden file support, excludes `.git` |
| `layout_strategy` | Horizontal with prompt at top |
| `sorting_strategy` | Ascending (closest match first) |

> Keybindings (`<leader>ff`, `<leader>fg`, `<leader>fb`, `<leader>fh`) are in `lua/config.lua`.

---

## File 7: `plugin/ui.lua` (~75 lines)

**Purpose:** All UI plugins — icons, git gutter, statusline, bufferline, terminal, file tree. Six plugins in one file, loaded in dependency order.

| # | Plugin | Source |
|---|---|---|
| 1 | nvim-web-devicons | `https://github.com/nvim-tree/nvim-web-devicons` |
| 2 | gitsigns.nvim | `https://github.com/lewis6991/gitsigns.nvim` |
| 3 | lualine.nvim | `https://github.com/nvim-lualine/lualine.nvim` |
| 4 | bufferline.nvim | `https://github.com/akinsho/bufferline.nvim` |
| 5 | toggleterm.nvim | `https://github.com/akinsho/toggleterm.nvim` |
| 6 | nvim-tree.lua | `https://github.com/nvim-tree/nvim-tree.lua` |

```lua
require("lazyload").on_vim_enter(function()
  -- ═══════════════════════════════════════════════════════════════
  -- 1. nvim-web-devicons — MUST load first (needed by lualine, bufferline, nvim-tree)
  -- ═══════════════════════════════════════════════════════════════
  vim.pack.add({
    { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  })
  require("nvim-web-devicons").setup({
    default = true,
  })

  -- ═══════════════════════════════════════════════════════════════
  -- 2. gitsigns.nvim — git gutter signs (+ ~ ─)
  -- ═══════════════════════════════════════════════════════════════
  vim.pack.add({
    { src = "https://github.com/lewis6991/gitsigns.nvim" },
  })
  require("gitsigns").setup({
    signs = {
      add          = { text = "▎" },
      change       = { text = "▎" },
      delete       = { text = "▎" },
      topdelete    = { text = "▎" },
      changedelete = { text = "▎" },
    },
    signcolumn = true,
    numhl = true,
    linehl = false,
    word_diff = false,
    watch_gitdir = { interval = 1000 },
    current_line_blame = true,
    current_line_blame_opts = {
      delay = 500,
    },
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns
      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end
      map("n", "]h", gs.next_hunk, { desc = "Next hunk" })
      map("n", "[h", gs.prev_hunk, { desc = "Previous hunk" })
    end,
  })

  -- ═══════════════════════════════════════════════════════════════
  -- 3. lualine.nvim — statusline (uncluttered, no separators)
  -- ═══════════════════════════════════════════════════════════════
  vim.pack.add({
    { src = "https://github.com/nvim-lualine/lualine.nvim" },
  })
  require("lualine").setup({
    options = {
      theme = "auto",
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
      disabled_filetypes = { "NvimTree", "toggleterm" },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff", "diagnostics" },
      lualine_c = { "filename" },
      lualine_x = { "encoding", "fileformat", "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
  })

  -- ═══════════════════════════════════════════════════════════════
  -- 4. barbar.nvim — bufferline (midpoint: lighter than bufferline, richer than mini.tabline)
  -- ═══════════════════════════════════════════════════════════════
  vim.pack.add({
    { src = "https://github.com/romgrk/barbar.nvim" },
  })
  require("barbar").setup({
    animation = false,           -- faster, no animation overhead
    auto_hide = true,            -- hide when only one buffer
    clickable = true,
    icons = {
      filetype = { enabled = true },
    },
    insert_at_end = true,
    maximum_padding = 1,
    minimum_padding = 1,
    maximum_length = 30,
    sidebar_filetypes = {
      NvimTree = true,
      toggleterm = true,
    },
  })

  -- ═══════════════════════════════════════════════════════════════
  -- 5. toggleterm.nvim — floating terminal (Alt-i, persistent session)
  -- ═══════════════════════════════════════════════════════════════
  vim.pack.add({
    { src = "https://github.com/akinsho/toggleterm.nvim" },
  })
  require("toggleterm").setup({
    open_mapping = [[<A-i>]],
    direction = "float",
    float_opts = {
      border = "curved",
      width = math.floor(vim.o.columns * 0.8),
      height = math.floor(vim.o.lines * 0.8),
    },
    persist_size = true,
    persist_mode = true,
    hide_numbers = true,
    shade_terminals = true,
    shading_factor = 2,
    start_in_insert = true,
    close_on_exit = false,
  })

  -- ═══════════════════════════════════════════════════════════════
  -- 6. nvim-tree.lua — file explorer (tuned for speed, git-aware)
  -- ═══════════════════════════════════════════════════════════════
  vim.pack.add({
    { src = "https://github.com/nvim-tree/nvim-tree.lua" },
  })
  require("nvim-tree").setup({
    sort = {
      sorter = "name",
      folders_first = true,
    },
    view = {
      width = 30,
      side = "left",
    },
    renderer = {
      group_empty = true,
      highlight_git = true,
      icons = {
        show = {
          git = true,
          folder = true,
          file = true,
          folder_arrow = true,
        },
      },
    },
    git = {
      enable = true,
      ignore = false,
    },
    filters = {
      dotfiles = false,
      custom = { "^\\.git$" },
    },
    actions = {
      open_file = {
        quit_on_open = false,
        resize_window = true,
      },
    },
    -- Disable filesystem watchers for speed
    filesystem_watchers = {
      enable = false,
    },
  })
end)
```

### UI Plugin Details

#### Gitsigns
| Feature | Detail |
|---|---|
| Gutter signs | `▎` for added, changed, deleted (minimal bar) |
| Line blame | Shows author + commit inline (after 500ms idle) |
| Keymaps | `]h` next hunk, `[h` previous hunk |
| Watch interval | 1 second git dir polling |

#### Lualine
| Section | Content |
|---|---|
| A | Mode (NORMAL, INSERT, etc.) |
| B | Git branch + diff stats + diagnostics count |
| C | Filename |
| X | Encoding + fileformat + filetype |
| Y | Progress (%) |
| Z | Line:Column |

#### Bufferline (NvChad-style)
| Setting | Detail |
|---|---|
| `separator_style = "thin"` | Clean line separators between tabs |
| `diagnostics = "nvim_lsp"` | Shows LSP diagnostics in buffer tabs |
| `offsets` | Indents for NvimTree and toggleterm sidebars |
| `show_buffer_close_icons = true` | Close button on each tab |
| `color_mode = "buffer"` | Current buffer has distinct colors |

#### Toggleterm
| Feature | Detail |
|---|---|
| Toggle | `Alt-i` — same session, show/hide |
| Style | Floating, 80%×80%, curved border |
| Session | Persists — toggle hides, doesn't kill |
| Insert | Starts in insert mode ready to type |

#### Nvim-Tree (speed tuning)
| Setting | Value | Reason |
|---|---|---|
| `filesystem_watchers` | `false` | No fs polling overhead |
| `git.enable` | `true` | Git state in tree |
| `git.ignore` | `false` | Show untracked files |
| `highlight_git` | `true` | Color files by git state |
| `sort.folders_first` | `true` | Directories before files |

---

## Complete Plugin Inventory (15 plugins)

| # | Plugin | Author | File | Load |
|---|---|---|---|---|
| 1 | crayon | dylanaraps | `init.lua` | Eager |
| 2 | nvim-treesitter | nvim-treesitter | `plugin/treesitter.lua` | Async |
| 3 | mason.nvim | williamboman | `plugin/lsp.lua` | Async |
| 4 | mason-lspconfig.nvim | williamboman | `plugin/lsp.lua` | Async |
| 5 | nvim-lspconfig | neovim | `plugin/lsp.lua` | Async |
| 6 | blink.cmp | saghen | `plugin/lsp.lua` | Async |
| 7 | blink.lib | saghen | `plugin/lsp.lua` | Async |
| 8 | plenary.nvim | nvim-lua | `plugin/telescope.lua` | Async |
| 9 | telescope.nvim | nvim-telescope | `plugin/telescope.lua` | Async |
| 10 | nvim-web-devicons | nvim-tree | `plugin/ui.lua` | Async |
| 11 | nvim-colorizer.lua | NvChad | `plugin/ui.lua` | Async |
| 12 | gitsigns.nvim | lewis6991 | `plugin/ui.lua` | Async |
| 13 | lualine.nvim | nvim-lualine | `plugin/ui.lua` | Async |
| 14 | barbar.nvim | romgrk | `plugin/ui.lua` | Async |
| 15 | toggleterm.nvim | akinsho | `plugin/ui.lua` | Async |
| 16 | nvim-tree.lua | nvim-tree | `plugin/ui.lua` | Async |

### Load Types

| Type | When | Used for |
|---|---|---|
| **Eager** | During `init.lua` (step 7b) | Colorscheme only |
| **Async** | After `VimEnter` via `vim.schedule` | All plugins (14 of 15) |

---

## Keybindings Reference

| Key | Action | Plugin / Source |
|---|---|---|
| `<leader>ff` | Find files | Telescope |
| `<leader>fg` | Live grep | Telescope |
| `<leader>fb` | Buffers | Telescope |
| `<leader>fh` | Help tags | Telescope |
| `<leader>gs` | Git status | Telescope |
| `<leader>gb` | Git branches | Telescope |
| `<leader>gc` | Git commits | Telescope |
| `<leader>mf` | Format current file | LSP |
| `<leader>ma` | Format all modified buffers | LSP |
| `<leader>rn` | Rename symbol | LSP |
| `<leader>ca` | Code action | LSP |
| `<leader>h` | Clear search highlight | Built-in |
| `<leader>?` | Show keymaps popup | which-key |
| `<C-n>` | Toggle file explorer | nvim-tree |
| `<C-h/j/k/l>` | Window navigation | Built-in |
| `<Tab>` / `<S-Tab>` | Next / prev buffer | bufferline |
| `<leader>bp` | Pick buffer (jump by letter) | bufferline |
| `Alt-i` | Toggle floating terminal | toggleterm |
| `gd` | Go to definition | LSP |
| `gr` | Go to references | LSP |
| `gI` | Go to implementation | LSP |
| `K` | Hover documentation | LSP |
| `[d` / `]d` | Prev/next diagnostic | LSP |
| `[h` / `]h` | Prev/next git hunk | gitsigns |

---

## Maintenance

### Installing plugins on a new machine
```bash
git clone <your-dotfiles> ~/.config/nvim
# Open Neovim — vim.pack.add() clones all plugins automatically
nvim
```

### Updating plugins
```vim
:lua vim.pack.update()
```
Opens a confirmation buffer. Navigate with `]]`/`[[`, inspect changes with `K`, accept with `:w`, cancel with `:q`.

### Locking versions across machines
```bash
git add nvim-pack-lock.json
git commit -m "nvim: update plugins"
```
On secondary machine: pull lockfile, `:restart`, then:
```vim
:lua vim.pack.update(nil, { target = 'lockfile' })
```

### Reverting a bad update
```bash
git checkout HEAD -- nvim-pack-lock.json
# :restart in Neovim
:lua vim.pack.update({ 'plugin-name' }, { offline = true, target = 'lockfile' })
```

### Installing LSP servers
```vim
:Mason              " Browse/install LSP servers, linters, formatters
:LspInstall <name>  " Install specific LSP server
```
Or just open a file — if the server is in `ensure_installed`, mason installs it automatically.

---

## Design Principles

1. **No third-party plugin manager** — `vim.pack` is built into Neovim 0.12+
2. **Deferred loading** — all plugins load after `VimEnter` (except colorscheme)
3. **Lazy activation** — treesitter parsers & LSP servers install on first filetype match, not at startup
4. **Few files** — 7 files total, consolidated where possible (<50 lines → merge)
5. **No cross-plugin opts** — each plugin config is self-contained, no `_G.Config` registry
6. **Built-in sources** — blink.cmp has LSP/path/snippet/buffer sources built-in, no extra source plugins
7. **Speed-conscious** — nvim-tree watchers off, indent-blankline debounce 500ms, colorizer lazy_load
8. **Diagnostic float** — no inline text running off screen; undercurl stays, float on hover after 750ms
