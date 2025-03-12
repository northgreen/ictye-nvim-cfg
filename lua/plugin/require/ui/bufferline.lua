--- use https://github.com/akinsho/bufferline.nvim to show bufferline in nvim
local h = {}
setmetatable(h, {
    __index = function(t, k)
        local _h = require'catppuccin.groups.integrations.bufferline'.get({
            styles = {'boid',"italic"}
        })
        rawset(t, k, _h)
		return _h
    end
})

return {
    'akinsho/bufferline.nvim',
    version = '*',
    enabled = not (options.env_var.firenvim or options.env_var.vscode),
    event = "VeryLazy",
    keys = {
        {"<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin"}, {
            "<leader>bP",
            "<Cmd>BufferLineGroupClose ungrouped<CR>",
            desc = "Delete Non-Pinned Buffers"
        }, {
            "<leader>br",
            "<Cmd>BufferLineCloseRight<CR>",
            desc = "Delete Buffers to the Right"
        }, {
            "<leader>bl",
            "<Cmd>BufferLineCloseLeft<CR>",
            desc = "Delete Buffers to the Left"
        }, {"<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer"},
        {"<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer"},
        {"[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer"},
        {"]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer"},
        {"[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev"},
        {"]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next"}
    },
    dependencies = {'catppuccin/nvim', 'nvim-tree/nvim-web-devicons'},
    opts = {
        options = {
            numbers = 'both',
            offsets = {{filetype = 'NvimTree', text = '󰙅  File Explorer'}},
            diagnostics = 'nvim_lsp',
            color_icons = false
        },
        highlights = h
    },
    config = function(_, opts)
        require("bufferline").setup(opts)
        vim.api.nvim_create_autocmd({"BufAdd", "BufDelete"},{
            callback = function()
                vim.schedule(function() pcall(nvim_bufferline) end)
            end
        })
    end
}

