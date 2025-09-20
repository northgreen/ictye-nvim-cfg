if vim.g.lite_mode then
    return
end

if _G.configed[vim.bo.filetype] then
  return
end
_G.configed[vim.bo.filetype] = true


local dap = require('dap')
local nvim_lsp = require('lspconfig')
-- local capabilities = require('cmp_nvim_lsp').default_capabilities()
local attach = require 'global.language.attach'.attach

vim.lsp.config('lua_ls',{
    -- capabilities = capabilities,
    on_init = function(client)
        local path = client.workspace_folders[1].name
        if not vim.loop.fs_stat(path .. '/.luarc.json') and
            not vim.loop.fs_stat(path .. '/.luarc.jsonc') then
            client.config.settings = vim.tbl_deep_extend('force', client.config
                                                             .settings, {
                Lua = {
                    runtime = {version = 'LuaJIT'},
                    workspace = {
                        checkThirdParty = false,
                        library = {vim.env.VIMRUNTIME}
                    }
                }
            })
            client.notify('workspace/didChangeConfiguration',
                          {settings = client.config.settings})
        end
        return true
    end,
    on_attach = attach
})

-- TODO:auto selove the problem of lua runtime path and debugger
local local_lua_debugger_vscode =
    "D:\\home\\documents\\proj\\local-lua-debugger-vscode"

dap.adapters["local-lua"] = {
    type = "executable",
    command = "node",
    args = {local_lua_debugger_vscode .. "/extension/debugAdapter.js"},
    enrich_config = function(config, on_config)
        if not config["extensionPath"] then
            local c = vim.deepcopy(config)
            c.extensionPath = local_lua_debugger_vscode
            on_config(c)
        else
            on_config(config)
        end
    end
}

dap.adapters.nlua = function(callback, config)
    callback({
        type = 'server',
        host = config.host or "127.0.0.1",
        port = config.port or 8086
    })
end

dap.configurations.lua = {
    {
        type = 'nlua',
        request = 'attach',
        name = "Attach to running Neovim instance"
    }, {
        name = 'Current file (local-lua-dbg, nvim lua)',
        type = 'local-lua',
        request = 'launch',
        cwd = '${workspaceFolder}',
        program = {
            lua = vim.fn.stdpath('config') .. '\\bin\\nlua.bat',
            file = '${file}'
        },
        verbose = true,
        args = {}
    }, {
        name = 'Current file (local-lua-dbg, lua)',
        type = 'local-lua',
        request = 'launch',
        cwd = '${workspaceFolder}',
        program = {
            lua = 'lua',
            file = '${file}'
        },
        verbose = true,
        args = {}
    }
}
