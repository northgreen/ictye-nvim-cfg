local Enable = vim.lsp.enable

-- Enabled Lsp seriver

Enable('autohotkey_lsp')
Enable('lua_ls')

-- Enable('csharp_ls')
Enable('powershell_es')
Enable('ruff')
Enable('jsonls')
Enable('solargraph')
-- Enable('cspell_ls')
Enable('pyright')
-- Enable('omnisharp')
Enable('roslyn')
Enable('fsautocomplete')
-- Enable('fsharp_language_server')
Enable('clangd')
Enable("cmake")
Enable('asm_lsp')
Enable('bashls')
Enable("lemminx")

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
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, { buffer = event.buf, desc = 'LSP: Toggle Inlay Hints' })
        end

        vim.keymap.set('n', '<C-]>',
            require('telescope.builtin').lsp_definitions
            , { buffer = event.buf, desc = 'LSP: Go To Define' })

        vim.keymap.set('n', 'gO',
            require('telescope.builtin').lsp_document_symbols,
            { buffer = event.buf, desc = 'LSP: Show Document Symbols' })

        vim.keymap.set('n', 'grt',
            require('telescope.builtin').lsp_type_definitions,
            { buffer = event.buf, desc = 'LSP: Show Document Symbols' })
    end
})

vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
        local bufnr = args.buf
        local ft = vim.bo[bufnr].filetype
        local no_lsp_ft = {
            "oil"
        }
        if vim.tbl_contains(no_lsp_ft, ft) then
            return
        end
        -- vim.lsp.start(vim.lsp.config['cspell_ls'])
    end,
})
