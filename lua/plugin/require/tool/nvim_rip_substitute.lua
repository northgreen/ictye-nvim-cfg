--- @return LazyPluginSpec
return {
	'chrisgrieser/nvim-rip-substitute',
	cmd = 'RipSubstitute',
	event = 'BufRead',
	opts = {},
	keys = {
		{
			'<leader>fs',
			function() require('rip-substitute').sub() end,
			mode = { 'n', 'x' },
			desc = ' rip substitute',
		},
	},
}
