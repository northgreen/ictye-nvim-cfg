if _G.configed[vim.bo.filetype] then
  return
end
_G.configed[vim.bo.filetype] = true

local attach = require'global.language.attach'.attach
require'lspconfig'.pyright.setup {
	on_attach = attach
}

require('lspconfig').ruff.setup({
  init_options = {
    settings = {
    }
  },
  on_attach = attach
})

-- TODO:config python dap
