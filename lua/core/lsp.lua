local Enable = vim.lsp.enable
local Config = vim.lsp.config


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
Enable('roslyn')
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
-- Enable("cl-lsp") -- cannot work
Enable("hyprls")

-- Enable("ts_ls")
Enable("vtsls")
Enable("vue_ls")

Enable("emmet_ls")
Enable("gopls")
Enable("cssls")

-- Enable("fennel_language_server")
-- Enable("emmet-language-server")
Enable("fennel_ls") -- better then fennel_language_server
Enable("ast_grep")
Enable("clojure-lsp")

-- The lsp below is not here, it config with the plugin
-- Rust
-- Haskell

-- below is the attach setting

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)

    -- Set position encoding to UTF-8 to avoid warnings
    if client and not client.offset_encoding then
      client.offset_encoding = "utf-8"
    end

    vim.diagnostic.config {
      virtual_text = true
    }

    local Keymap = vim.keymap.set

    if client and client:supports_method(vim.lsp.protocol.Methods.testDocument_inlayHint) then
      Keymap('n', '<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
      end, { buffer = event.buf, desc = 'LSP: Toggle Inlay Hints' })
    end


    local Telescope = require('telescope.builtin')
    local themes = require('telescope.themes')
    local theme_opt = {}
    Keymap('n', 'gd',
      function() Telescope.lsp_definitions(themes.get_cursor(theme_opt)) end
      , { buffer = event.buf, desc = 'LSP: Go To Define' })

    Keymap('n', 'gO',
      function() Telescope.lsp_document_symbols(themes.get_cursor(theme_opt)) end,
      { buffer = event.buf, desc = 'LSP: Show Document Symbols' })

    Keymap('n', 'gD', vim.lsp.buf.declaration,
    { buffer = event.buf, desc = 'Go to Declaration' })

    Keymap('n', 'gi', vim.lsp.buf.implementation,
    { buffer = event.buf, desc = 'Go to Implementation' })

    Keymap('n', 'grt',
      function() Telescope.lsp_type_definitions(themes.get_cursor(theme_opt)) end,
      { buffer = event.buf, desc = 'LSP: Show Type Definitions' })

    Keymap('n', 'grc',
      function() Telescope.lsp_incoming_calls(themes.get_cursor(theme_opt)) end,
      { buffer = event.buf, desc = 'LSP: Show Incoming Calls' })

    Keymap('n', 'gra',
      function() vim.lsp.buf.code_action() end,
      { buffer = event.buf, desc = 'LSP: Show Incoming Calls' })

    Keymap('n', 'gro',
      function() Telescope.lsp_outgoing_calls(themes.get_cursor(theme_opt)) end,
      { buffer = event.buf, desc = 'LSP: Show Outgoing Calls' })

    Keymap('n', 'grr',
      function() Telescope.lsp_references(themes.get_cursor(theme_opt)) end,
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
