if vim.g.lite_mode then
    return
end

if _G.configed[vim.bo.filetype] then
  return
end
_G.configed[vim.bo.filetype] = true

local attach = require'global.language.attach'.attach

vim.lsp.config("ruff",{
  init_options = {
    settings = {
    }
  },
  on_attach = attach
})

-- TODO:config python dap
