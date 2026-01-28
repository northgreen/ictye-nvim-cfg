return {
    'echasnovski/mini.nvim',
    version = false,
    opts = {
        map     = {
            symbols = {
                encode = "█",
            }
        },
        move = {

        },
        pick    = {},
        align   = {},
        files   = {
            options = {
                use_as_default_explorer = false,
            },
            windows = {
                preview = true
            }
        },
        animate = {},
        diff = {},

    },
    config = function(_, opts)
        -- require('mini.map').setup(opts.map)
        require('mini.pick') .setup(opts.pick)
        require('mini.align').setup(opts.align)
        require('mini.files').setup(opts.files)

        -- if not vim.g.GUI then
            -- require('mini.animate').setup(opts.animate)
        -- end
        require('mini.move').setup(opts.move)
        require('mini.diff').setup(opts.diff)
    end
}
