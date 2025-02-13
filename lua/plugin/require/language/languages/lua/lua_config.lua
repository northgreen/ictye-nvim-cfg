local dap = require('dap')
local nvim_lsp = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local navic = require("nvim-navic")

nvim_lsp.lua_ls.setup({
    capabilities = capabilities,
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
	on_attach = function(client, buffer)
		navic.attach(client, buffer)
	end
})


dap.configurations.lua = {
  {
    type = 'nlua',
    request = 'attach',
    name = 'Attach to running Neovim instance',
  }
}

