local bufferline = require('bufferline')
bufferline.setup({
	options = {
		numbers = "original",
		offsets = {
			{
				filetype = "NvimTree",
				text = "File Explorer"
			}
		},
		hover = {
			enabled = true,
			delay = 200,
			reveal = {'close'}
		}
    }
})
