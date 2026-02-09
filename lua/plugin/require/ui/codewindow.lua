return {
    'gorbit99/codewindow.nvim',
    event = 'BufReadPre',
    opts = {
        minimap_width = 10
    },
    config = function(_,cfg)
        local codewindow = require('codewindow')
        codewindow.setup(cfg)
        codewindow.apply_default_keybinds()
    end,
}
