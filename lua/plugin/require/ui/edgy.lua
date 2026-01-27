return {
    "folke/edgy.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
        opts = {
            top = {

            },
            bottom = {
                { ft = 'trouble',              tittle = 'Files' },
                { ft = 'neotest-output-panel', tittle = 'Test Output' },
            },
            left = {
                { ft = 'neo-tree', tittle = "Tree" },
                { ft = 'Outline',  tittle = 'OverView', size = { height = 0.4 } },
            },
            right = {
                { ft = 'neotest-summary' },
                { ft = 'opencode_terminal',  tittle = 'OpenCode', size = { width = 0.3 } }
            }
        }
        for _, pos in ipairs({ "top", "bottom", "left", "right" }) do
            opts[pos] = opts[pos] or {}
            table.insert(opts[pos], {
                ft = "snacks_terminal",
                size = { height = 0.4 },
                title = "%{b:snacks_terminal.id}: %{b:term_title}",
                filter = function(_buf, win)
                    return vim.w[win].snacks_win
                        and vim.w[win].snacks_win.position == pos
                        and vim.w[win].snacks_win.relative == "editor"
                        and not vim.w[win].trouble_preview
                end,
            })
        end
        return opts
    end
}
