--- @return LazyPluginSpec
return {
    'MagicDuck/grug-far.nvim',
	event = 'BufRead',
    config = function()
        require('grug-far').setup({
        });
    end
}
