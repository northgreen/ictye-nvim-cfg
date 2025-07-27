local dap = require("dap")
local lspconfig = require 'lspconfig'
lspconfig.clangd.setup({capabilities = capabilities})
lspconfig.cmake.setup({capabilities = capabilities})

dap.configurations.cpp = {
  {
    name = "Launch file",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
  },
}

dap.configurations.c = dap.configurations.cpp
