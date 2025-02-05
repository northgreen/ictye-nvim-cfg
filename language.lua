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

mason.setup()
mason_lspconfig.setup({})

-- Set up nvim-cmp.
local cmp = require 'cmp'
local lspkind = require ("lspkind")

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
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
            -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
            -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
            -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
            -- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
        end
    },
    window = {
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({select = true}) -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
        {name = 'nvim_lsp'},
		{name = 'vsnip'},
		{name = 'path'},
		{name = 'buffer'},
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
local capabilities = require('cmp_nvim_lsp').default_capabilities()

nvim_lsp.lua_ls.setup({
    capabilities = capabilities,
    on_init = function(client)
        local path = client.workspace_folders[1].name
        if not vim.loop.fs_stat(path .. "/.luarc.json") and
            not vim.loop.fs_stat(path .. "/.luarc.jsonc") then
            client.config.settings = vim.tbl_deep_extend("force", client.config
                                                             .settings, {
                Lua = {
                    runtime = {version = "LuaJIT"},
                    workspace = {
                        checkThirdParty = false,
                        library = {vim.env.VIMRUNTIME}
                    }
                }
            })
            client.notify("workspace/didChangeConfiguration",
                          {settings = client.config.settings})
        end
        return true
    end
})

require'lspconfig'.clangd.setup({capabilities = capabilities})

require'lspconfig'.cmake.setup({capabilities = capabilities})

require'lspconfig'.html.setup({capabilities = capabilities})

