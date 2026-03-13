return {
    'saghen/blink.cmp',
    dependencies = {
        'rafamadriz/friendly-snippets',
        'xzbdmw/colorful-menu.nvim',
        'Kaiser-Yang/blink-cmp-avante',
        { 'L3MON4D3/LuaSnip', version = 'v2.*' }
    },

    version = '1.*',

    event = { 'BufReadPost', 'BufNewFile' },

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
        signature = {
            enabled = true,
        },

        keymap = {
            preset = 'default',
            ['<C-j>'] = { 'select_next', 'fallback' },
            ['<C-k>'] = { 'select_prev', 'fallback' },
        },
        appearance = {
            nerd_font_variant = 'mono'
        },
        sources = {
            default = { 'avante', 'snippets', 'lsp', 'path', 'buffer' },
            providers = {
                -- fittencode = {
                --     name = "fittencode",
                --     module = "fittencode.sources.blink",
                -- },
                avante = {
                    module = 'blink-cmp-avante',
                    name = 'Avante',
                    opts = {}
                },
            }
        },
        fuzzy = { implementation = "prefer_rust_with_warning" },
        snippets = { preset = "luasnip" },
        completion = {
            documentation =
            {
                window = {
                    border = 'single',
                },
                auto_show = true
            },
            menu = {
                border = 'single',
                draw = {
                    columns = { { "kind_icon" }, { "label", gap = 1 } },
                    components = {
                        label = {
                            width = { fill = true, max = 60 },
                            text = function(ctx)
                                local highlights_info = require("colorful-menu").blink_highlights(ctx)
                                if highlights_info ~= nil then
                                    return highlights_info.label
                                else
                                    return ctx.label
                                end
                            end,
                            highlight = function(ctx)
                                local highlights = {}
                                local highlights_info = require("colorful-menu").blink_highlights(ctx)
                                if highlights_info ~= nil then
                                    highlights = highlights_info.highlights
                                end
                                for _, idx in ipairs(ctx.label_matched_indices) do
                                    table.insert(highlights, { idx, idx + 1, group = "BlinkCmpLabelMatch" })
                                end
                                return highlights
                            end,
                        },
                    },
                },
            },
        },
    },
    opts_extend = { "sources.default" }
}
