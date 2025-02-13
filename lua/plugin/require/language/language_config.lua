-- mason.lua
local mason_status, mason = pcall(require, 'mason')
if not mason_status then
    vim.notify('没有找到 mason')
    return
end

local nlsp_status, nvim_lsp = pcall(require, 'lspconfig')
if not nlsp_status then
    vim.notify('没有找到 lspconfig')
    return
end

local mlsp_status, mason_lspconfig = pcall(require, 'mason-lspconfig')
if not mlsp_status then
    vim.notify('没有找到 mason-lspconfig')
    return
end




mason.setup({ui = require('plugin.require.ui.mason_ui')})
mason_lspconfig.setup()

local dap = require('dap')
local dapui = require('dapui')

dap.listeners.before.attach.dapui_config = function() dapui.open() end
dap.listeners.before.launch.dapui_config = function() dapui.open() end
dap.listeners.before.event_terminated.dapui_config =
    function() dapui.close() end
dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

vim.opt.completeopt = {'noselect', 'noinsert'}
vim.opt.complete = ''

local capabilities = require('cmp_nvim_lsp').default_capabilities()

require'lspconfig'.clangd.setup({capabilities = capabilities})
require'lspconfig'.cmake.setup({capabilities = capabilities})
require'lspconfig'.html.setup({capabilities = capabilities})

require 'plugin.require.language.languages.rust.rust_config'
require 'plugin.require.language.languages.json.json_config'
require 'plugin.require.language.languages.lua.lua_config'
require 'plugin.require.language.languages.python.python_config'
require 'plugin.require.language.languages.c_cpp.c_cpp_config'

require 'plugin.require.language.toolchain.toolchain_init'

dapui.setup()
require'lspconfig'.phan.setup {}

