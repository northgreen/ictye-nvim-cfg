local Enable = vim.lsp.enable
local Config = vim.lsp.config


Config('roslyn', {
    settings = {
        ["csharp|code_lens"] = {
            dotnet_enable_reference_code_lens = true
        }
    }
})

-- Enabled Lsp seriver

Enable('autohotkey_lsp')
Enable('lua_ls')

Enable("qmlls")
-- Enable('csharp_ls')
Enable('powershell_es')
Enable('ruff')
Enable('jsonls')
Enable('solargraph')
-- Enable('cspell_ls')
Enable('pyright')
-- Enable('omnisharp')
Enable('roslyn')
-- local ionide_config = require("ionide").setup({})
-- vim.lsp.config("fsautocomplete", ionide_config)
Enable('fsautocomplete') -- already enabled by default
-- Enable('fsharp_language_server')
Enable('clangd')
Enable("cmake")
Enable('asm_lsp')
Enable('bashls')
Enable("lemminx")

Enable("glslls")
Enable("gdscript")
-- Enable("gdshader_lsp") -- not very eazy to use......
Enable("cl-lsp")
Enable("hyprls")
-- Enable("ts_ls")
Enable("vtsls")
Enable("vue_ls")
Enable("emmet_ls")
-- Enable("emmet-language-server")
Enable("gopls")


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

        local Keymap = vim.keymap.set

        if client and client:supports_method(vim.lsp.protocol.Methods.testDocument_inlayHint) then
            Keymap('n', '<leader>th', function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, { buffer = event.buf, desc = 'LSP: Toggle Inlay Hints' })
        end


        Keymap('n', '<C-]>',
            require('telescope.builtin').lsp_definitions
            , { buffer = event.buf, desc = 'LSP: Go To Define' })

        Keymap('n', 'gO',
            require('telescope.builtin').lsp_document_symbols,
            { buffer = event.buf, desc = 'LSP: Show Document Symbols' })

        Keymap('n', 'grt',
            require('telescope.builtin').lsp_type_definitions,
            { buffer = event.buf, desc = 'LSP: Show Type Definitions' })

        Keymap('n', 'grr',
            require('telescope.builtin').lsp_references,
            { buffer = event.buf, desc = 'LSP: Show References' })

        Keymap('n', 'grf',
            vim.lsp.buf.format,
            { buffer = event.buf, desc = 'LSP: Format Buffer' })
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
