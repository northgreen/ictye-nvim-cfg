return {
    "folke/edgy.nvim",
    event = "VeryLazy",
    opts = {
        bottom = {
            {ft = 'trouble', tittle = 'Files'},
            {ft = 'neotest-output-panel', tittle = 'Test Output'},
        },
        left = {
            -- {ft = 'neo-tree'},
            {ft = 'Outline', tittle = 'OverView', size = {height = 0.4}}
        },
        right = {
            {ft = 'neotest-summary'}
        }
    }
}
