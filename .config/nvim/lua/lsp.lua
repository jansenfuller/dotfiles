require("nvchad.configs.lspconfig").defaults()

vim.lsp.config('yamlls', {
  settings = {
    yaml = {
      schemas = {
        ["https://raw.githubusercontent.com/yannh/kubernetes-json-schema/refs/heads/master/v1.32.1-standalone-strict/all.json"] = "/*.k8s.yaml",
      }
    }
  }
})

vim.lsp.config('gopls', {
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
      gofumpt = true,
    }
  }
})


vim.lsp.config('dockerls', {
  settings = {
    docker = {
	    languageserver = {
        formatter = {
          ignoreMultilineInstructions = true,
        }
	    }
    }
  }
})

local servers = { "html", "cssls", "yamlls", "bashls", "gopls", "ts_ls", "dockerls", "expert"}
vim.lsp.enable(servers)
