if vim.g.lite_mode then
  return
end

if _G.configured[vim.bo.filetype] then
  return
end
_G.configured[vim.bo.filetype] = true
