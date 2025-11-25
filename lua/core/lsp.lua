local Enable = vim.lsp.enable

-- Enabled Lsp seriver 

Enable('autohotkey_lsp')
Enable('lua_ls')
-- Enable('csharp_ls')
Enable('powershell_es')
Enable('ruff')
Enable('jsonls')
Enable('solargraph')
Enable('cspell_ls')
Enable('pyright')
-- Enable('omnisharp')
Enable('roslyn')

-- The lsp below is not here, it config with the plugin
-- Rust
-- Haskell

-- below is the attach setting

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
    callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        vim.diagnostic.config {
            virtual_text = true
        }

        if client and client:supports_method(vim.lsp.protocol.Methods.testDocument_inlayHint) then
            vim.keymap.set('n', '<leader>th', function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled {bufnr = event.buf})
            end, { buffer = event.buf, desc = 'LSP: Toggle Inlay Hints' })
        end

        vim.keymap.set('n','<C-]>',
            require('telescope.builtin').lsp_definitions
            ,{ buffer = event.buf, desc = 'LSP: Go To Define' })

        vim.keymap.set('n','gO',
            require('telescope.builtin').lsp_document_symbols,
            { buffer = event.buf, desc = 'LSP: Show Document Symbols' })

        vim.keymap.set('n','gO',
            require('telescope.builtin').lsp_document_symbols,
            { buffer = event.buf, desc = 'LSP: Show Document Symbols' })

    end
})
