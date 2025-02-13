--- @return LazyPluginState
return {
    'hrsh7th/nvim-cmp',
    opts = function(_, opts)
        opts.sources = opts.sources or {}
        table.insert(opts.sources, {name = 'lazydev', group_index = 0})
    end,
    config = function()
        local cmp = require 'cmp'
        local lspkind = require 'lspkind'

        cmp.setup({
            formatting = {
                format = lspkind.cmp_format({
                    with_text = true,
                    maxwidth = 50,
                    before = function(entry, vim_item)
                        vim_item.menu =
                            '[' .. string.upper(entry.source.name) .. ']'
                        return vim_item
                    end
                })
            },
            snippet = {
                expand = function(args)
                    vim.fn['vsnip#anonymous'](args.body)
                end
            },
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered()
            },
            mapping = cmp.mapping.preset.insert({
                ['<Tab>'] = cmp.mapping(function(fallback)
                    -- This little snippet will confirm with tab, and if no entry is selected, will confirm the first item
                    if cmp.visible() then
                        local entry = cmp.get_selected_entry()
                        if not entry then
                            cmp.select_next_item({
                                behavior = cmp.SelectBehavior.Select
                            })
                        end
                        cmp.confirm()
                    else
                        fallback()
                    end
                end, {'i', 's', 'c'})
            }),
            sources = cmp.config.sources({
                {name = 'nvim_lsp'}, {name = 'vsnip'}, {name = 'path'},
                {name = 'coc'}, {name = 'buffer'},
                {name = 'fittencode', group_index = 1}
            })
        })

        cmp.setup.cmdline({'/', '?'}, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {{name = 'buffer'}}
        })

        cmp.setup.cmdline(':', {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config
                .sources({{name = 'path'}}, {{name = 'cmdline'}}),
            matching = {disallow_symbol_nonprefix_matching = false}
        })

    end,
    dependencies = {
        'onsails/lspkind.nvim', 'hrsh7th/cmp-buffer', 'hrsh7th/cmp-path',
        'hrsh7th/cmp-nvim-lua', 'hrsh7th/cmp-nvim-lsp',
        {'hrsh7th/cmp-vsnip', dependencies = {'hrsh7th/vim-vsnip'}}
    }
}
