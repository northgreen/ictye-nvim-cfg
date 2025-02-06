local bufferline = require('bufferline')
bufferline.setup({
	options = {
		numbers = "raise",
		offsets = {
			{
				filetype = "NvimTree",
				text = "File Explorer"
			}
		},
		diagnostics = "coc",
		color_icons = false,
    },
	highlights = require("catppuccin.groups.integrations.bufferline").get({
	})
})

