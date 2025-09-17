return {
    'hrsh7th/nvim-cmp',
    opts = function(_, opts)
        opts.sources = opts.sources or {}
        table.insert(opts.sources, {name = 'lazydev', group_index = 0})
    end,
    events = {'BufReadPre'},
    lazy = true,
    config = function()
        local cmp = require 'cmp'
        local lspkind = require 'lspkind'

        cmp.setup({
            formatting = {
                expandable_indicator = true,
                fields = {'abbr', 'kind', 'menu'},
                format = function(entry, item)
                    local color_item = require("nvim-highlight-colors")
                                      .format(entry, {kind = item.kind})
                    item = lspkind.cmp_format({
                        mode = 'symbol_text',
                        symbol_map = options.ui.symbal_map,
                        before = function(rentry, vim_item)
                            vim_item.menu = '[' ..
                                                string.upper(rentry.source.name) ..
                                                ']'
                            return vim_item
                        end
                    })(entry, item)
                    if color_item.abbr_hl_group then
                        item.kind_hl_group = color_item.abbr_hl_group
                        item.kind = color_item.abbr
                    end
                    return item
                end
            },
            snippet = {
                expand = function(args)
                    vim.fn['vsnip#anonymous'](args.body)
                end
            },
            window = {
                completion = cmp.config.window.bordered({zindex = 40}),
                documentation = cmp.config.window.bordered({zindex = 40})
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
                end, {'i', 's', 'c'}),
                ['<C-j>'] = cmp.mapping.select_next_item({'i', 's', 'c'}),
                ['<C-k>'] = cmp.mapping.select_prev_item({'i', 's', 'c'})
            }),
            sources = cmp.config.sources({
                {name = 'nvim_lsp'}, {name = 'vsnip'}, {name = 'path'},
                {name = 'eazy-dotnet'}, {name = 'buffer'},
                {name = 'fittencode', group_index = 1},{name = 'avante'},
                {name = "sonicpi"}
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
        'hrsh7th/cmp-nvim-lua',
        {'hrsh7th/cmp-nvim-lsp', events = {'BufReadPre'}}, {
            'hrsh7th/cmp-vsnip',
            dependencies = {'hrsh7th/vim-vsnip-integ', 'hrsh7th/vim-vsnip'}
        }
    }
}
