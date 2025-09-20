if vim.g.lite_mode then
    return
end

if _G.configed[vim.bo.filetype] then
    return
end
_G.configed[vim.bo.filetype] = true

local on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[bufnr].omnifunc= 'v:lua.vim.lsp.omnifunc'

    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', '<Leader>ca', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', '<Leader>f', function() vim.lsp.buf.format { async = true } end, bufopts)
    vim.keymap.set('n', '<Leader>rn', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<Leader>td', vim.lsp.buf.type_definition, bufopts)
end

local home_directory = os.getenv('HOME')
if home_directory == nil then
    home_directory = os.getenv('USERPROFILE')
end

-- The bundle_path is where PowerShell Editor Services was installed
local bundle_path = home_directory .. '/Desktop/PowerShellEditorServices'

vim.lsp.config('powershell_es', {
    bundle_path = bundle_path,
    on_attach = on_attach
})
