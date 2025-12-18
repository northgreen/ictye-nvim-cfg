return {
    "Freed-Wu/rime.nvim",
	enabled = false,
	opts = {},
    config = function(_,opt)
        -- require('rime.nvim').setup(opt)
        local ui = require('ime.ui')

        local rime = require('rime.nvim')
        rime.rime = { ui = ui.UI { indices = ui.styles.square } }
        vim.keymap.set('i', '<C-^>', rime.toggle)
        vim.keymap.set('i', '<C-@>', rime.enable)
        vim.keymap.set('i', '<C-_>', rime.disable)
        vim.keymap.set('i', '<C-\\>', rime.callback('<C-\\>'))
    end,
    dependencies = {
        {
            "rimeinn/ime.nvim"
        }
    }
}
