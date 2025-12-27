--- use https://github.com/akinsho/bufferline.nvim to show bufferline in nvim
return {
    'akinsho/bufferline.nvim',
    version = '*',
    enabled = not (options.env_var.firenvim or options.env_var.vscode),
    -- enabled = false,
    event = "VeryLazy",
    keys = {
        { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" }, {
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
    }, { "<S-h>",   "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
        { "<S-l>",      "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
        { "[b",         "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
        { "]b",         "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
        { "[B",         "<cmd>BufferLineMovePrev<cr>",  desc = "Move buffer prev" },
        { "]B",         "<cmd>BufferLineMoveNext<cr>",  desc = "Move buffer next" }
    },
    dependencies = { 'catppuccin/nvim', 'nvim-tree/nvim-web-devicons', "catppuccin/nvim" },
    opts = {
        options = {
            themeable = true,
            numbers = function(opts)
                return string.format('%s.%s', opts.ordinal, opts.raise(opts.id))
            end,
            offsets = {
                { filetype = 'NvimTree', text = '󰙅  File Explorer' },
                { filetype = 'neo-tree', },
                { filetype = 'Outline', text = '  Outline' },
                { filetype = 'Dashboard', text = '  Dashboard' }
            },
            diagnostics = 'nvim_lsp',
            indicator = { icon = '▎' },
            color_icons = false,
        },
    },
    config = function(_, opts)
        local frappe = require("catppuccin.palettes").get_palette('frappe')
        local _h = require 'catppuccin.special.bufferline'.get_theme({
            styles = { 'boid', "italic" },
            custom = { frappe = { fill = { bg = frappe.crust } } }
        })

        local bufferline = require('bufferline')
        opts.highlights = _h

        bufferline.setup(opts)
        vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" },
            {
                callback = function()
                    vim.schedule(function() pcall(nvim_bufferline) end)
                end
            })
    end
}
