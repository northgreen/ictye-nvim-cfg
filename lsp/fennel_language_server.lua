---@brief
---
--- https://github.com/rydesun/fennel-language-server
---
--- Fennel language server protocol (LSP) support.

---@type vim.lsp.Config
return {
  cmd = { 'fennel-language-server' },
  filetypes = { 'fennel' },
  root_markers = { '.git' },
  settings = {
    fennel = {
      workspace = {
        -- If you are using hotpot.nvim or aniseed,
        -- make the server aware of neovim runtime files.
        library = vim.api.nvim_list_runtime_paths(),
      },
      diagnostics = {
        globals = { 'vim' },
      },
    },
  },
  capabilities = require("global.language.capabilities")(),
}
