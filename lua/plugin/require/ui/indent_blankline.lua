--- @return LazyPluginSpec
return {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {},
	event = 'BufRead',
    config = function()
		require('ibl').setup({
		indent = {char = '┆'}
	})
	end
}
