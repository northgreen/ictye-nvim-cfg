--- use https://github.com/akinsho/bufferline.nvim to show bufferline in nvim
return {
    'akinsho/bufferline.nvim',
    version = '*',
    enabled = not (options.env_var.firenvim or options.env_var.vscode),
    -- enabled = false,
    event = "VeryLazy",
    keys = require("core.keymap").bufferline,
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
                { filetype = 'Dashboard', text = '  Dashboard' },
                { filetype = 'opencode_terminal', text = 'OpenCode' },
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
