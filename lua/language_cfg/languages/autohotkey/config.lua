local capabilities = vim.lsp.protocol.make_client_capabilities()

local ahk2_configs = {
    autostart = true,
    cmd = {
        "node",
        vim.fn.expand("$HOME/vscode-autohotkey2-lsp/server/dist/server.js"),
        "--stdio"
    },
    filetypes = {"ahk", "autohotkey", "ah2"},
    init_options = {
        locale = "zh-cn",
        InterpreterPath = "C:/Program Files/AutoHotkey/v2/AutoHotkey.exe",
        AutoLibInclude = "All",
        CommentTags = "^;;\\s*(?<tag>.+)",
        FormatOptions = {
            array_style = "none",
            break_chained_methods = false,
            ignore_comment = false,
            indent_string = "\t",
            max_preserve_newlines = 2,
            brace_style = "One True Brace",
            object_style = "none",
            preserve_newlines = true,
            space_after_double_colon = true,
            space_before_conditional = true,
            space_in_empty_paren = false,
            space_in_other = true,
            space_in_paren = false,
            wrap_line_length = 0
        },
	SymbolFoldingFromOpenBrace = true,
    },
	single_file_support = true,
    flags = {debounce_text_changes = 500},
    capabilities = capabilities,
    on_attach = require'global.language.attach'.attach
}

local configs = require "lspconfig.configs"
configs["ahk2"] = {default_config = ahk2_configs}
local nvim_lsp = require("lspconfig")
nvim_lsp.ahk2.setup({})
