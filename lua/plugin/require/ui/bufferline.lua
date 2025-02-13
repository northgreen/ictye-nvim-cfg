--- use https://github.com/akinsho/bufferline.nvim to show bufferline in nvim
--- @return LazyPluginSpec
return {
    'akinsho/bufferline.nvim',
    version = '*',
	enabled = not vim.g.started_by_firenvim,
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
        local bufferline = require('bufferline')
        bufferline.setup({
            options = {
                numbers = 'both',
                offsets = {{filetype = 'NvimTree', text = '󰙅  File Explorer'}},
                diagnostics = 'nvim_lsp',
                color_icons = false
            },
			highlights = require('catppuccin.groups.integrations.bufferline').get({
				styles = {'boid'},
			})
        })
    end
}

