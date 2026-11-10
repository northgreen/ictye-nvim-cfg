if vim.g.lite_mode then
  return
end

if _G.configured[vim.bo.filetype] then
  return
end
_G.configured[vim.bo.filetype] = true

--Enable (broadcasting) snippet capability for completion
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

vim.lsp.config("jsonls", {
  capabilities = capabilities,
})
