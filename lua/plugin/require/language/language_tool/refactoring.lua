--- @return LazyPluginSpec
return {
    'ThePrimeagen/refactoring.nvim',
    dependencies = {'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter'},
	event = 'BufRead',
    config = function()
		require('refactoring').setup({})
	end
}
