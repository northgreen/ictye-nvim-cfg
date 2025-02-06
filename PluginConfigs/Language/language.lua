local nvim_lsp = require 'lspconfig'
-- mason.lua
local mason_status, mason = pcall(require, "mason")
if not mason_status then
    vim.notify("没有找到 mason")
    return
end

local nlsp_status, nvim_lsp = pcall(require, "lspconfig")
if not nlsp_status then
    vim.notify("没有找到 lspconfig")
    return
end

local mlsp_status, mason_lspconfig = pcall(require, "mason-lspconfig")
if not mlsp_status then
    vim.notify("没有找到 mason-lspconfig")
    return
end

mason.setup({ui = require("PLuginConfigs.UI.mason_ui")})
mason_lspconfig.setup({})

-- Set up nvim-cmp.
local cmp = require 'cmp'
local lspkind = require("lspkind")

local dap = require("dap")
local dapui = require("dapui")

dap.listeners.before.attach.dapui_config = function() dapui.open() end
dap.listeners.before.launch.dapui_config = function() dapui.open() end
dap.listeners.before.event_terminated.dapui_config =
    function() dapui.close() end
dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

vim.opt.completeopt = {'noselect', 'noinsert'}
vim.opt.complete = ""

cmp.setup({
    formatting = {
        format = lspkind.cmp_format({
            with_text = true,
            maxwidth = 50,
            before = function(entry, vim_item)
                vim_item.menu = "[" .. string.upper(entry.source.name) .. "]"
                return vim_item
            end
        })
    },
    snippet = {
        expand = function(args)
			vim.fn["vsnip#anonymous"](args.body)
        end
    },
	window = {
		completion = cmp.config.window.bordered(),
		documentation=cmp.config.window.bordered(),
	},
    mapping = cmp.mapping.preset.insert({
        ["<Tab>"] = cmp.mapping(function(fallback)
            -- This little snippet will confirm with tab, and if no entry is selected, will confirm the first item
            if cmp.visible() then
                local entry = cmp.get_selected_entry()
                if not entry then
                    cmp.select_next_item({behavior = cmp.SelectBehavior.Select})
                end
                cmp.confirm()
            else
                fallback()
            end
        end, {"i", "s", "c"})
    }),
    sources = cmp.config.sources({
        {name = 'nvim_lsp'}, {name = 'vsnip'}, {name = 'path'},{name='coc'},
        {name = 'buffer'}, {name = 'fittencode',group_index = 1}
	})
})

cmp.setup.cmdline({'/', '?'}, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {{name = 'buffer'}}
})

cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({{name = 'path'}}, {{name = 'cmdline'}}),
    matching = {disallow_symbol_nonprefix_matching = false}
})

-- Set up lspconfig.
vim.cmd(
[[
 let g:tagbar_type_rust = {
    \ 'ctagstype' : 'rust',
    \ 'kinds' : [
        \'T:types,type definitions',
        \'f:functions,function definitions',
        \'g:enum,enumeration names',
        \'s:structure names',
        \'m:modules,module names',
        \'c:consts,static constants',
        \'t:traits',
        \'i:impls,trait implementations',
    \]
    \}
]]
)

local capabilities = require('cmp_nvim_lsp').default_capabilities()

require'lspconfig'.clangd.setup({capabilities = capabilities})
require'lspconfig'.cmake.setup({capabilities = capabilities})
require'lspconfig'.html.setup({capabilities = capabilities})

require('PluginConfigs.Language.rust')
require('PluginConfigs.Language.json')
require('PluginConfigs.Language.lua')
require('PluginConfigs.Language.toolchain.toolchain_init')


dapui.setup()
require('lspconfig').phan.setup{}
