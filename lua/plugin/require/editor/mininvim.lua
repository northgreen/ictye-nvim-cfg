return {
    'echasnovski/mini.nvim',
    version = false,
    opts = {
        map     = {
            symbols = {
                encode = █,
            }
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
    },
    config = function(_, opts)
        -- require('mini.map').setup(opts.map)
        require('mini.pick').setup(opts.pick)
        require('mini.align').setup(opts.align)
        require('mini.files').setup(opts.files)
        -- require('mini.animate').setup(opts.animate)
    end
}
