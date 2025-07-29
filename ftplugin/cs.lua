if vim.g.lite_mode then
    return
end

if _G.configed[vim.bo.filetype] then
  return
end
_G.configed[vim.bo.filetype] = true

require'lspconfig'.csharp_ls.setup{}
